# frozen_string_literal: true

require_relative "lib/jekyll_privatus_analytics/version"

Gem::Specification.new do |spec|
  spec.name = "jekyll-privatus-analytics"
  spec.version = JekyllPrivatusAnalytics::VERSION
  spec.authors = ["Two Phase LLC"]
  spec.email = ["james@privatusanalytics.com"]

  spec.summary = "Cookieless Privatus Analytics tracking script for Jekyll sites."
  spec.description = "Liquid tags for the Privatus Analytics tracking script, custom events and click maps, " \
                     "with optional automatic injection into every page. The script sets no cookies, so " \
                     "analytics does not need a consent banner by itself."
  spec.homepage = "https://privatusanalytics.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.metadata = {
    "homepage_uri" => "https://privatusanalytics.com",
    "source_code_uri" => "https://github.com/Privatus-Analytics/jekyll",
    "changelog_uri" => "https://github.com/Privatus-Analytics/jekyll/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/Privatus-Analytics/jekyll/issues",
    "documentation_uri" => "https://privatusanalytics.com/docs",
    "rubygems_mfa_required" => "true"
  }

  spec.files = Dir["lib/**/*.rb", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "jekyll", ">= 3.10", "< 5"
end
