# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "jekyll", ENV.fetch("JEKYLL_VERSION", "~> 4.4")
# Jekyll 3 sites need the GFM Markdown parser listed by hand. Jekyll 4 already depends on it.
gem "kramdown-parser-gfm", "~> 1.1"
gem "minitest", "~> 5.25"
gem "rake", "~> 13.2"
gem "rubocop", "~> 1.75", require: false
gem "rubocop-minitest", "~> 0.37", require: false
gem "rubocop-rake", "~> 0.7", require: false
