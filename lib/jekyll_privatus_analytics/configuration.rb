# frozen_string_literal: true

module JekyllPrivatusAnalytics
  # Reads the `privatus_analytics:` settings from _config.yml.
  class Configuration
    DEFAULT_HOST = "https://privatusstats.com"
    SPA_MODES = %w[auto history hash off].freeze
    DEFAULT_ENVIRONMENTS = %w[production].freeze

    def self.for_site(site)
      new(site.config["privatus_analytics"])
    end

    def initialize(settings = {})
      @settings = settings.is_a?(Hash) ? settings.transform_keys(&:to_s) : {}
    end

    # A raw setting, for example self["modules"].
    def [](name)
      @settings[name.to_s]
    end

    # The site id (starts with pa_). Falls back to ENV["PRIVATUS_SITE_ID"].
    def site_id
      value = self["site_id"].to_s.strip
      value = ENV.fetch("PRIVATUS_SITE_ID", "").strip if value.empty?
      value.empty? ? nil : value
    end

    # Origin that serves /js/pa.js. Falls back to ENV["PRIVATUS_SCRIPT_HOST"].
    def script_host
      value = self["script_host"].to_s.strip
      value = ENV.fetch("PRIVATUS_SCRIPT_HOST", "").strip if value.empty?
      value = DEFAULT_HOST if value.empty?
      value.chomp("/")
    end

    # `enabled: true` or `false` forces it. Otherwise on when JEKYLL_ENV is in enabled_environments.
    def enabled?(environment = Jekyll.env)
      enabled = self["enabled"]
      return enabled == true unless enabled.nil?

      environments = self["enabled_environments"]
      environments = DEFAULT_ENVIRONMENTS if environments.nil?
      Array(environments).map(&:to_s).include?(environment.to_s)
    end

    def auto_inject?
      self["auto_inject"] == true
    end

    def extra_attributes
      value = self["extra_attributes"]
      value.is_a?(Hash) ? value : {}
    end

    def props
      value = self["props"]
      value.is_a?(Hash) ? value : {}
    end
  end
end
