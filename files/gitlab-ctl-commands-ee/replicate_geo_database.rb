require "#{base_path}/embedded/service/omnibus-ctl-ee/lib/geo/replication"
require 'optparse'

add_command_under_category('replicate-geo-database', 'gitlab-geo', 'Replicate Geo database', 2) do |_cmd_name, *args|
  GeoReplicationCommand.new(self, ARGV).execute!
end

class GeoReplicationCommand
  def initialize(ctl, args)
    @ctl = ctl
    @args = args

    @options = {
      user: 'gitlab_replicator',
      port: 5432,
      host: nil,
      password: nil,
      now: false,
      force: false,
      skip_backup: false,
      slot_name: nil,
      skip_replication_slot: false,
      backup_timeout: 1800,
      sslmode: 'verify-full',
    }

    parse_options!
  end

  def execute!
    Geo::Replication.new(@ctl, @options).execute
  end

  def arguments
    @args.dup
  end

  private

  def parse_options!
    opts_parser = OptionParser.new do |opts|
      opts.banner = 'Usage: gitlab-ctl replicate-geo-database [options]'

      opts.separator ''
      opts.separator 'Specific @options:'

      opts.on('--host=HOST', 'Hostname address of the primary node') do |host|
        @options[:host] = host
      end

      opts.on('--user[=USER]', 'Specify a different replication user') do |user|
        @options[:user] = user
      end

      opts.on('--port[=PORT]', 'Specify a different PostgreSQL port') do |port|
        @options[:port] = port
      end

      opts.on('--slot-name[=SLOT-NAME]', 'PostgreSQL replication slot name') do |slot_name|
        @options[:slot_name] = slot_name
      end

      opts.on('--no-wait', 'Do not wait before starting the replication process') do
        @options[:now] = true
      end

      opts.on('--backup-timeout[=BACKUP_TIMEOUT]', 'Specify the timeout for the initial database backup from the primary.') do |backup_timeout|
        @options[:backup_timeout] = backup_timeout.to_i
      end

      opts.on('--force', 'Disable existing database even if instance is not empty') do
        @options[:force] = true
      end

      opts.on('--skip-backup', 'Skip the backup before starting the replication process') do
        @options[:skip_backup] = true
      end

      opts.on('--skip-replication-slot', 'Skip the check and creation of replication slot') do
        @options[:skip_replication_slot] = true
      end

      opts.on('--sslmode=MODE', 'Choose the level of protection the connection between primary and secondary has.') do |sslmode|
        @options[:sslmode] = sslmode
      end

      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    opts_parser.parse!(arguments)

    raise OptionParser::MissingArgument.new(:host) unless @options.fetch(:host)
    raise OptionParser::MissingArgument.new('--slot-name') unless @options[:skip_replication_slot] || @options.fetch(:slot_name)
  rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    puts $!.to_s
    puts opts_parser
    exit 1
  end
end
