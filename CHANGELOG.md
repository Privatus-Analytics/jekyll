# Changelog

## 1.0.0 - 2026-10-25

- Initial release.
- `{% privatus_analytics %}` Liquid tag, with per-call settings.
- `{% privatus_event %}` for custom events and `{% privatus_click %}` for click map names.
- Optional `auto_inject` that adds the tag to the head of every page and document.
- Settings under `privatus_analytics` in _config.yml. The tag is on only when `JEKYLL_ENV` is
  `production`, unless `enabled` is set.
- Page props from `props` in _config.yml, merged with `privatus_props` from front matter.
- With `queue_stub: true`, `{% privatus_analytics %}` now prints the queue stub and nothing else when the
  tag is off (development, `enabled: false` or no site id), so `privatus.track` calls never fail. Before, it
  printed nothing.
- With `queue_stub: true`, automatic injection (`auto_inject: true`) now also adds the queue stub alone to
  every page when the tag is off (no tracker, no page props script). A page that already prints the stub with
  `{% privatus_analytics %}` does not get a second one. With the queue stub off nothing is added, as before.
- `example/`: a tiny site for the Privatus conformance tests, built with the plugin and served by nginx.
