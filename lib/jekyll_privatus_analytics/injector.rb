# frozen_string_literal: true

module JekyllPrivatusAnalytics
  # Adds the tag just before </head> in every HTML page and document.
  # Off unless `auto_inject: true` is set under privatus_analytics in _config.yml.
  module Injector
    HEAD_CLOSE = %r{</head>}i

    module_function

    def call(item)
      configuration = Configuration.for_site(item.site)
      return unless configuration.auto_inject? && html?(item)

      tag = Tag.new(configuration, "page_props" => item.data["privatus_props"])
      # Like a server middleware, auto inject adds nothing when the tag is off (not even the queue stub).
      return unless tag.render?

      item.output = inject(item.output, tag.to_s)
    end

    def html?(item)
      item.output.is_a?(String) && item.output_ext == ".html"
    end

    # Only the head is checked for the tag, so a page that shows the snippet as text still gets it.
    def inject(html, tag)
      match = HEAD_CLOSE.match(html)
      return html if tag.empty? || match.nil? || match.pre_match.include?(Tag::MARKER)

      "#{match.pre_match}#{tag}\n#{match}#{match.post_match}"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  JekyllPrivatusAnalytics::Injector.call(item)
end
