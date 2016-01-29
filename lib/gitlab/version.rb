module Gitlab
  class Version

    def initialize(filename)
      @filename = filename
      filepath = File.expand_path(@filename, Omnibus::Config.project_root)
      @read_version = File.read(filepath).chomp
    rescue Errno::ENOENT
      # Didn't find the file
      @read_version = ""
    end

    def print
      case @filename
      when "VERSION"
        version == "master" ? version : "v#{version}"
      when "GITLAB_SHELL_VERSION"
        version == "master" ? version : "v#{version}"
      when "GITLAB_WORKHORSE_VERSION"
        version
      else
        nil
      end
    end

    def version
      if @read_version.include?('.pre')
        "master"
      elsif @read_version.empty?
        nil
      else
        @read_version
      end
    end

    def remote
      case @filename
      when "VERSION"
        if @read_version.include?('-ee')
          "git@dev.gitlab.org:gitlab/gitlab-ee.git"
        else
          "git@dev.gitlab.org:gitlab/gitlabhq.git"
        end
      when "GITLAB_SHELL_VERSION"
        "git@dev.gitlab.org:gitlab/gitlab-shell.git"
      when "GITLAB_WORKHORSE_VERSION"
        "git@dev.gitlab.org:gitlab/gitlab-workhorse.git"
      else
        nil
      end
    end
  end
end
