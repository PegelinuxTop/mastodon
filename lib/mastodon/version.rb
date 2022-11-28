# frozen_string_literal: true

module Mastodon
  module Version
    module_function

    def major
      4
    end

    def minor
      0
    end

    def patch
      2
    end

    def flags
      ''
    end

    def suffix
      '+glitch+th'
    end

    def to_a
      [major, minor, patch].compact
    end

    def to_s
      [to_a.join('.'), flags, suffix].join
    end

    def repository
      ENV.fetch('GIT_REPOSITORY', false) || ENV.fetch('GITHUB_REPOSITORY', false) || 'treehouse/mastodon'
    end

    def source_base_url
      ENV.fetch('SOURCE_BASE_URL', "https://gitea.treehouse.systems/#{repository}")
    end

    # specify git tag or commit hash here
    def source_tag
      ENV.fetch('SOURCE_TAG', nil)
    end

    def source_url
      if source_tag && source_base_url =~ /gitea/
        suffix = if !str[/\H/]
                   "commit/#{source_tag}"
                 else
                   "branch/#{source_tag}"
                 end
        "#{source_base_url}/#{suffix}"
      else
        source_base_url
      end
    end

    def user_agent
      @user_agent ||= "#{HTTP::Request::USER_AGENT} (Mastodon/#{Version}; +http#{Rails.configuration.x.use_https ? 's' : ''}://#{Rails.configuration.x.web_domain}/)"
    end
  end
end
