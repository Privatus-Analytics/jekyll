# frozen_string_literal: true

require "cgi"

module JekyllPrivatusAnalytics
  # Builds the script tag. Returns an empty string when no tag should print.
  #
  # Before the tracker tag it can also print the queue stub (queue_stub) and the
  # page props script (props), each with the nonce when there is one.
  class Tag
    LIST_OPTIONS = { "modules" => "data-modules", "excluded_paths" => "data-exclude",
                     "domains" => "data-domains" }.freeze
    PROPS_FUNCTION = "privatusPageProps"
    MARKER = "/js/pa.js"
    QUEUE_STUB = "window.privatus=window.privatus||{q:[]};['track','pageview','props','optOut','optIn','ready']" \
                 ".forEach(function(m){window.privatus[m]=window.privatus[m]||function(){window.privatus.q.push(" \
                 "[m,Array.prototype.slice.call(arguments)])}})"

    # overrides: any setting by name, plus "page_props" (the page's privatus_props front matter).
    # Props are merged in this order: _config.yml, front matter, the "props" override. nil removes one.
    def initialize(configuration, overrides = {})
      @configuration = configuration
      @overrides = (overrides || {}).transform_keys(&:to_s)
    end

    def render?
      !site_id.nil? && enabled?
    end

    def to_s
      return "" unless render?

      props_json = PageProps.json(page_props)
      html = []
      html << inline_script(QUEUE_STUB) if option("queue_stub") == true
      html << inline_script("window.#{PROPS_FUNCTION}=function(){return #{props_json}}") if props_json
      html << script_tag(props_json ? { "data-props" => PROPS_FUNCTION } : {})
      html.join("\n")
    end

    def attributes
      attrs = { "defer" => true, "src" => "#{script_host}#{MARKER}", "data-site" => site_id }
      add_options(attrs)
      @configuration.extra_attributes.each { |name, value| attrs[name.to_s] = value unless value.nil? }
      attrs["nonce"] = nonce if nonce
      attrs
    end

    def page_props
      [@configuration.props, @overrides["page_props"], @overrides["props"]].reduce({}) do |merged, layer|
        merged.merge(keyed(layer))
      end
    end

    private

    def site_id
      value = @overrides["site_id"].to_s.strip
      value.empty? ? @configuration.site_id : value
    end

    def script_host
      value = @overrides["script_host"].to_s.strip
      value.empty? ? @configuration.script_host : value.chomp("/")
    end

    def enabled?
      @overrides.key?("enabled") ? @overrides["enabled"] == true : @configuration.enabled?
    end

    def nonce
      value = option("nonce").to_s
      value.empty? ? nil : value
    end

    def script_tag(more)
      parts = attributes.merge(more).map do |name, value|
        value == true ? name : %(#{name}="#{CGI.escapeHTML(value.to_s)}")
      end
      "<script #{parts.join(' ')}></script>"
    end

    def inline_script(code)
      opening = nonce ? %(<script nonce="#{CGI.escapeHTML(nonce)}">) : "<script>"
      "#{opening}#{code}</script>"
    end

    def keyed(props)
      return {} unless props.is_a?(Hash)

      props.transform_keys { |key| Attributes.normalize_key(key) }
    end

    def add_options(attrs)
      LIST_OPTIONS.each do |name, attribute|
        values = list(option(name))
        # nil keeps the tracker default. An empty modules list loads none.
        attrs[attribute] = values.join(",") if values && (name == "modules" || !values.empty?)
      end
      spa = option("spa").to_s
      attrs["data-spa"] = spa if Configuration::SPA_MODES.include?(spa) && spa != "auto"
      attrs["data-manual"] = "true" if option("manual") == true
    end

    def option(name)
      @overrides.key?(name) ? @overrides[name] : @configuration[name]
    end

    # nil stays nil. Anything else becomes a clean array of strings.
    def list(value)
      return nil if value.nil?

      Array(value).flat_map { |item| item.to_s.split(",") }.map(&:strip).reject(&:empty?)
    end
  end
end
