# frozen_string_literal: true

require "test_helper"

class CoreTest < Minitest::Test
  Attributes = JekyllPrivatusAnalytics::Attributes
  PageProps = JekyllPrivatusAnalytics::PageProps
  Configuration = JekyllPrivatusAnalytics::Configuration
  Tag = JekyllPrivatusAnalytics::Tag

  BASIC = '<script defer src="https://privatusstats.com/js/pa.js" data-site="pa_TEST123456"></script>'

  def tag(settings = {}, overrides = {})
    Tag.new(Configuration.new({ "site_id" => "pa_TEST123456", "enabled" => true }.merge(settings)), overrides).to_s
  end

  def test_basic_snippet
    assert_equal BASIC, tag
  end

  def test_nothing_without_a_site_id_or_when_off
    assert_equal "", tag("site_id" => nil)
    assert_equal "", tag("enabled" => false)
  end

  def test_production_only_by_default
    config = Configuration.new("site_id" => "pa_X")

    assert config.enabled?("production")
    refute config.enabled?("development")
    assert Configuration.new("enabled_environments" => %w[staging]).enabled?("staging")
  end

  def test_options
    html = tag("modules" => %w[engage auto], "excluded_paths" => ["/admin/*"], "domains" => "a.com, b.com",
               "spa" => "hash", "manual" => true)

    assert_includes html, 'data-modules="engage,auto"'
    assert_includes html, 'data-exclude="/admin/*"'
    assert_includes html, 'data-domains="a.com,b.com"'
    assert_includes html, 'data-spa="hash"'
    assert_includes html, 'data-manual="true"'
  end

  def test_empty_modules_and_spa_defaults
    assert_includes tag("modules" => []), 'data-modules=""'
    refute_includes tag("spa" => "auto"), "data-spa"
    refute_includes tag("spa" => "bogus"), "data-spa"
  end

  def test_escaping_extras_and_nonce
    html = tag({ "excluded_paths" => ['/a"b'], "extra_attributes" => { "data-mask" => "/o/*->/o/:id" } },
               "nonce" => "abc")

    assert_includes html, 'data-exclude="/a&quot;b"'
    assert_includes html, 'data-mask="/o/*-&gt;/o/:id"'
    assert_includes html, 'nonce="abc"'
  end

  def test_props_script_and_queue_stub
    parts = tag({ "props" => { "plan" => "docs" }, "queue_stub" => true }, "nonce" => "n").split("\n")

    assert_equal %(<script nonce="n">#{Tag::QUEUE_STUB}</script>), parts[0]
    assert_equal '<script nonce="n">window.privatusPageProps=function(){return {"plan":"docs"}}</script>', parts[1]
    assert_includes parts[2], 'data-props="privatusPageProps"'
  end

  def test_props_layers_merge_and_nil_removes
    html = tag({ "props" => { "plan" => "docs", "role" => "x" } },
               "page_props" => { "Role" => nil, "section" => "guides" }, "props" => { "tier" => 2 })

    assert_includes html, '{"plan":"docs","section":"guides","tier":2}'
  end

  def test_env_fallbacks
    ENV["PRIVATUS_SITE_ID"] = "pa_ENV"
    ENV["PRIVATUS_SCRIPT_HOST"] = "https://stats.example.com/"
    config = Configuration.new

    assert_equal "pa_ENV", config.site_id
    assert_equal "https://stats.example.com", config.script_host
  ensure
    ENV.delete("PRIVATUS_SITE_ID")
    ENV.delete("PRIVATUS_SCRIPT_HOST")
  end

  def test_page_props_json
    assert_nil PageProps.json({})
    assert_equal '{"seats":5,"ratio":1.5,"beta":true,"flags":["a","b",3]}',
                 PageProps.json(seats: 5, ratio: 1.5, beta: true, flags: ["a", nil, "b", 3])
    assert_equal 30, JSON.parse(PageProps.json((1..40).to_h { |i| [:"p#{i}", i] })).size
  end

  def test_page_props_json_is_script_safe
    assert_equal '{"note":"\\u003c/script\\u003e\\u0026\\u2028\\u2029"}', PageProps.json(note: "</script>&\u2028\u2029")
  end

  def test_event_attributes
    assert_equal({ "data-privatus-event" => "Export CSV", "data-privatus-prop-report_type" => "a",
                   "data-privatus-prop-on" => "true", "data-privatus-prop-tags" => "a,b" },
                 Attributes.event("  Export CSV ", "Report Type" => "a", on: true, tags: %w[a b], gone: nil))
    assert_empty Attributes.event("  ")
    assert_equal "a" * 120, Attributes.event("a" * 200)["data-privatus-event"]
  end

  def test_click_attributes
    assert_equal({ "data-privatus-click" => "pricing.cta" }, Attributes.click("pricing.cta"))
    ["", "has space", "x" * 101, "<b>", nil].each { |name| assert_empty Attributes.click(name) }
  end
end
