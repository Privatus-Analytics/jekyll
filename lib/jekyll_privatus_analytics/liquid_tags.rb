# frozen_string_literal: true

module JekyllPrivatusAnalytics
  # {% privatus_analytics %} prints the script tag. Named arguments override settings for this call:
  #   {% privatus_analytics modules="engage,auto" queue_stub=true %}
  class AnalyticsTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @arguments = Arguments.new(markup)
    end

    def render(context)
      site = context.registers[:site]
      page = context.registers[:page] || {}
      overrides = @arguments.options(context)
      overrides["page_props"] = page["privatus_props"]
      Tag.new(Configuration.for_site(site), overrides).to_s
    end
  end

  # {% privatus_event "Export CSV" format="csv" source="toolbar" %} prints the event data attributes.
  # They print in every environment. They do nothing without the tracker.
  class EventTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @arguments = Arguments.new(markup)
    end

    def render(context)
      Attributes.to_html(Attributes.event(@arguments.first(context), @arguments.options(context)))
    end
  end

  # {% privatus_click "pricing.cta" %} prints the click map name attribute, or nothing when not valid.
  class ClickTag < Liquid::Tag
    def initialize(tag_name, markup, parse_context)
      super
      @arguments = Arguments.new(markup)
    end

    def render(context)
      name = @arguments.first(context)
      return Attributes.to_html(Attributes.click(name)) if Attributes.valid_click?(name)

      unless Jekyll.env == "production"
        Jekyll.logger.warn("Privatus:", "click map name #{name.inspect} is not valid. Use letters, digits " \
                                        "and _ . : - only, at most 100 characters. Nothing was printed.")
      end
      ""
    end
  end
end

Liquid::Template.register_tag("privatus_analytics", JekyllPrivatusAnalytics::AnalyticsTag)
Liquid::Template.register_tag("privatus_event", JekyllPrivatusAnalytics::EventTag)
Liquid::Template.register_tag("privatus_click", JekyllPrivatusAnalytics::ClickTag)
