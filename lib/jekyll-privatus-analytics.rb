# frozen_string_literal: true

require "jekyll"
require "jekyll_privatus_analytics/version"
require "jekyll_privatus_analytics/attributes"
require "jekyll_privatus_analytics/page_props"
require "jekyll_privatus_analytics/configuration"
require "jekyll_privatus_analytics/tag"
require "jekyll_privatus_analytics/arguments"
require "jekyll_privatus_analytics/liquid_tags"
require "jekyll_privatus_analytics/injector"

# Adds the cookieless Privatus Analytics tracking script to Jekyll sites.
#
# The plugin only prints the browser script and HTML attributes. It never sends events from the build.
module JekyllPrivatusAnalytics
end
