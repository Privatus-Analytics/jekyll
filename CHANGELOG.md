# Changelog

## Unreleased

- With `queue_stub: true`, `{% privatus_analytics %}` now prints the queue stub and nothing else when the
  tag is off (development, `enabled: false` or no site id), so `privatus.track` calls never fail. Before, it
  printed nothing. Automatic injection still adds nothing when the tag is off.
- `example/`: a tiny site for the Privatus conformance tests, built with the plugin and served by nginx.

## 1.0.0 - 2026-10-25

- Initial release.
- `{% privatus_analytics %}` Liquid tag, with per-call settings.
- `{% privatus_event %}` for custom events and `{% privatus_click %}` for click map names.
- Optional `auto_inject` that adds the tag to the head of every page and document.
- Settings under `privatus_analytics` in _config.yml. The tag is on only when `JEKYLL_ENV` is
  `production`, unless `enabled` is set.
- Page props from `props` in _config.yml, merged with `privatus_props` from front matter.
