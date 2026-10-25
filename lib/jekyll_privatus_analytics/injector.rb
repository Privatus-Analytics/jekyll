# frozen_string_literal: true

module JekyllPrivatusAnalytics
  # Adds the tag just before </head> in every HTML page and document.
  # Off unless `auto_inject: true` is set under privatus_analytics in _config.yml.
  module Injector
    HEAD_CLOSE = %r{</head>}i
    # A real queue stub script (with or without a nonce). Shown as text in a code block,
    # the "<script" is escaped, so it does not match.
    STUB_SCRIPT = /<script\b[^>]*>#{Regexp.escape(Tag::QUEUE_STUB[0, 40])}/

    module_function

    def call(item)
      configuration = Configuration.for_site(item.site)
      return unless configuration.auto_inject? && html?(item)

      tag = Tag.new(configuration, "page_props" => item.data["privatus_props"])
      # When the tag is off, to_s is the queue stub alone (queue_stub on) or "", and props are not used.
      item.output = inject(item.output, tag.to_s)
    end

    def html?(item)
      item.output.is_a?(String) && item.output_ext == ".html"
    end

    # Only the head is checked for the tag, so a page that shows the snippet as text still gets it.
    # The queue stub alone (the tag is off) is skipped when the page already prints a stub anywhere,
    # for example from {% privatus_analytics %}, so a page never gets two.
    def inject(html, tag)
      match = HEAD_CLOSE.match(html)
      return html if tag.empty? || match.nil? || match.pre_match.include?(Tag::MARKER)
      return html if !tag.include?(Tag::MARKER) && html.match?(STUB_SCRIPT)

      "#{match.pre_match}#{tag}\n#{match}#{match.post_match}"
    end
  end
end

Jekyll::Hooks.register [:pages, :documents], :post_render do |item|
  JekyllPrivatusAnalytics::Injector.call(item)
end
