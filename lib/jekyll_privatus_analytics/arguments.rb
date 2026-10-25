# frozen_string_literal: true

module JekyllPrivatusAnalytics
  # Reads Liquid tag arguments like: "Export CSV" format="csv" rows=page.rows beta=true
  #
  # Quoted text stays text. true, false, nil and numbers become those values.
  # Anything else is looked up as a Liquid variable, like page.title.
  class Arguments
    TOKEN = /(?:([A-Za-z0-9_-]+)\s*=\s*)?("(?:[^"]*)"|'(?:[^']*)'|[^\s"']+)/
    NUMBER = /\A-?\d+(\.\d+)?\z/
    LITERALS = { "true" => true, "false" => false, "nil" => nil, "null" => nil }.freeze

    attr_reader :positional, :named

    def initialize(markup)
      @positional = []
      @named = []
      markup.to_s.scan(TOKEN) do |key, value|
        key ? @named << [key, value] : @positional << value
      end
    end

    # The first unnamed argument, resolved.
    def first(context)
      positional.empty? ? nil : resolve(positional.first, context)
    end

    # The named arguments as a hash, resolved.
    def options(context)
      named.to_h { |key, value| [key, resolve(value, context)] }
    end

    private

    def resolve(token, context)
      return token[1..-2] if token.start_with?('"', "'")
      return LITERALS[token] if LITERALS.key?(token)
      return (token.include?(".") ? token.to_f : token.to_i) if token.match?(NUMBER)

      context[token]
    end
  end
end
