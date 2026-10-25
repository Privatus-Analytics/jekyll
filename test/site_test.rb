# frozen_string_literal: true

require "test_helper"

class SiteTest < Minitest::Test
  include SiteBuilder

  TAG = '<script defer src="https://privatusstats.com/js/pa.js" data-site="pa_TEST123456"></script>'
  SITE = { "site_id" => "pa_TEST123456" }.freeze

  def test_tag_prints_in_production
    pages = build_site(settings: SITE)

    assert_includes head(pages["index.html"]), TAG
    refute_includes pages["2026/10/01/hello.html"], "/js/pa.js"
  end

  def test_tag_prints_nothing_in_development_or_without_a_site_id
    refute_includes build_site(settings: SITE, env: "development")["index.html"], "/js/pa.js"
    refute_includes build_site(settings: {})["index.html"], "/js/pa.js"
  end

  def test_enabled_true_forces_it_on_in_development
    pages = build_site(settings: SITE.merge("enabled" => true), env: "development")

    assert_includes pages["index.html"], TAG
  end

  def test_front_matter_props_and_tag_arguments
    files = { "index.md" => <<~MD }
      ---
      layout: default
      title: Home
      privatus_props:
        section: guides
      ---
      {% privatus_analytics modules="engage,auto" queue_stub=true %}
    MD
    html = build_site(settings: SITE.merge("props" => { "docs_version" => "2.4" }), files: files)["index.html"]

    assert_includes head(html), '{return {"docs_version":"2.4","section":"guides"}}'
    assert_includes html, 'data-modules="engage,auto"'
    assert_includes html, "window.privatus=window.privatus||{q:[]}"
  end

  def test_event_and_click_tags
    files = { "features.html" => <<~HTML }
      ---
      layout: plain
      format: csv
      ---
      <button {% privatus_event "Export CSV" format=page.format source="toolbar" rows=10 %}>Export</button>
      <a href="/pricing" {% privatus_click "pricing.cta" %}>Pricing</a>
      <a {% privatus_click "not valid" %}>Bad</a>
      <i {% privatus_event "" %}></i>
    HTML
    html = build_site(settings: {}, files: files, env: "development")["features.html"]

    assert_includes html, '<button data-privatus-event="Export CSV" data-privatus-prop-format="csv" ' \
                          'data-privatus-prop-source="toolbar" data-privatus-prop-rows="10">Export</button>'
    assert_includes html, '<a href="/pricing" data-privatus-click="pricing.cta">Pricing</a>'
    assert_includes html, "<a >Bad</a>"
    assert_includes html, "<i ></i>"
  end

  def test_event_tag_escapes_html
    files = { "x.html" => %(---\nlayout: plain\n---\n<b {% privatus_event "Say <hi>" note='a"&b' %}></b>\n) }
    html = build_site(files: files)["x.html"]

    assert_includes html, 'data-privatus-event="Say &lt;hi&gt;" data-privatus-prop-note="a&quot;&amp;b"'
  end

  def test_auto_inject_adds_the_tag_to_every_page_once
    files = { "404.html" => "---\nlayout: plain\n---\nNot found <code>/js/pa.js</code>\n",
              "raw.html" => "<html><head></head><body>raw</body></html>\n" }
    pages = build_site(settings: SITE.merge("auto_inject" => true), files: files)

    %w[index.html 2026/10/01/hello.html 404.html].each do |path|
      assert_equal 1, head(pages[path]).scan("/js/pa.js").size, path
    end
    assert_includes head(pages["404.html"]), TAG
    refute_includes pages["raw.html"], "/js/pa.js"
  end

  def test_auto_inject_uses_front_matter_props_and_is_off_in_development
    files = { "_posts/2026-10-01-hello.md" => "---\nlayout: plain\nprivatus_props:\n  kind: post\n---\nHi\n" }
    settings = SITE.merge("auto_inject" => true)

    assert_includes build_site(settings: settings, files: files)["2026/10/01/hello.html"], '{return {"kind":"post"}}'
    refute_includes build_site(settings: settings, files: files, env: "development")["2026/10/01/hello.html"],
                    "/js/pa.js"
  end
end
