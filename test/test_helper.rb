# frozen_string_literal: true

require "minitest/autorun"
require "fileutils"
require "tmpdir"
require "jekyll-privatus-analytics"

module SiteBuilder
  LAYOUT = <<~HTML
    <!doctype html>
    <html>
    <head>
    <title>{{ page.title }}</title>
    {{ content_for_head }}
    </head>
    <body>{{ content }}</body>
    </html>
  HTML

  # Builds a tiny real Jekyll site and returns { "index.html" => html, ... }.
  # files: path => content, merged over a default site. settings: the privatus_analytics config.
  def build_site(settings: {}, files: {}, env: "production")
    Dir.mktmpdir("privatus-jekyll") do |dir|
      source = File.join(dir, "src")
      destination = File.join(dir, "_site")
      default_files.merge(files).each do |path, content|
        full = File.join(source, path)
        FileUtils.mkdir_p(File.dirname(full))
        File.write(full, content)
      end
      with_env("JEKYLL_ENV" => env) do
        config = Jekyll.configuration("source" => source, "destination" => destination, "quiet" => true,
                                      "privatus_analytics" => settings)
        Jekyll::Site.new(config).process
      end
      Dir.glob("**/*.html", base: destination).to_h { |path| [path, File.read(File.join(destination, path))] }
    end
  end

  def default_files
    {
      "_layouts/default.html" => LAYOUT.sub("{{ content_for_head }}", "{% privatus_analytics %}"),
      "_layouts/plain.html" => LAYOUT.sub("{{ content_for_head }}", ""),
      "index.md" => "---\nlayout: default\ntitle: Home\n---\n# Home\n",
      "_posts/2026-10-01-hello.md" => "---\nlayout: plain\ntitle: Hello\n---\nHello\n"
    }
  end

  def with_env(values)
    saved = values.keys.to_h { |key| [key, ENV.fetch(key, nil)] }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    saved.each { |key, value| ENV[key] = value }
  end

  def head(html)
    html.split("</head>").first
  end
end
