# Privatus Analytics for Jekyll

**Simple, private website analytics for your Jekyll site. No cookies, honest numbers,
and a dashboard you understand in seconds.**

## Why Privatus Analytics

**Google Analytics is slow, confusing and hungry for data.** It sends what your
visitors do to Google. In many countries it means showing a cookie pop-up (the box
that asks visitors to accept cookies), and many people click "reject", so you never
see them. Bots pad the numbers that are left.

**Privatus Analytics fixes that.** It counts visits to your Jekyll site without cookies and
never stores IP addresses. Bots are filtered out before they are counted. Your
data is never sold or shared.

What you get:

- **A dashboard you understand in seconds.** Visitors, top pages and where people
  came from, all on one screen.
- **No cookie pop-up needed for our analytics.** We set no cookies and store no
  personal data. Laws differ by country, so check your own legal advice.
- **Honest numbers.** Known bots and fake traffic are left out on every plan.
- **A fast site.** The tracking script is about 3 KB, tiny next to most tracking tags.
- **Data you own.** We never sell it or show you ads, and you can pull it out
  any time through the API.

**Start free.** The Free plan has 10,000 events a month and 3 sites, with no card.
Every new account also gets 14 days of Pro free, with no card.
[Create your account](https://privatusanalytics.com).

## What this package does

- A [Jekyll](https://jekyllrb.com) plugin that adds the tracking script with a
  Liquid tag, or adds it to every page for you.
- Liquid tags for custom events and click maps.
- The plugin only prints the browser script and HTML attributes. It never sends
  events from your computer or build server and sets no cookies.

You need a Privatus Analytics account to see your reports, and there is a
free plan. [Sign up at privatusanalytics.com](https://privatusanalytics.com).

## Requirements

* Ruby 3.1 or later.
* Jekyll 3.10 to 4.x.
* A Privatus Analytics site id (it starts with `pa_`). You find it under
  Site settings, Tracking.

### A note on GitHub Pages

The classic GitHub Pages build (the one that runs when you pick a branch under
Settings, Pages, with no workflow of your own) only runs a short, fixed list of
plugins. This plugin is not on that list, so **it does not run in classic
GitHub Pages builds**. Your site still builds, but without the tag.

You can still host on GitHub Pages. Build the site with GitHub Actions instead:
in your repository go to Settings, Pages, and set Source to "GitHub Actions",
then use the Jekyll starter workflow GitHub offers there. With Actions, any
plugin in your `Gemfile` runs. The starter workflow already sets
`JEKYLL_ENV=production`, which this plugin needs (see below).

If you must stay on the classic build, paste the plain script tag from your
Privatus Analytics site settings into your layout's `<head>` instead.

## Install

Add the gem to the plugins group of your `Gemfile`:

```ruby
group :jekyll_plugins do
  gem "jekyll-privatus-analytics"
end
```

Then run `bundle install`. Gems in the `jekyll_plugins` group load by
themselves. If you do not use that group, list the plugin in `_config.yml`
instead:

```yaml
plugins:
  - jekyll-privatus-analytics
```

For the full setup guide and every tracker option, see the [Privatus Analytics
docs](https://privatusanalytics.com/docs).

Set your site id in `_config.yml`:

```yaml
privatus_analytics:
  site_id: pa_YOURSITEID
```

or with an environment variable on your build machine:

```sh
PRIVATUS_SITE_ID=pa_YOURSITEID
```

## Add the tag

Put the tag in the `<head>` of your layout, for example `_layouts/default.html`
(or `_includes/head.html` in many themes):

```liquid
<head>
  <title>{{ page.title }}</title>
  {% privatus_analytics %}
</head>
```

When you build with `JEKYLL_ENV=production` it prints:

```html
<script defer src="https://privatusstats.com/js/pa.js" data-site="pa_YOURSITEID"></script>
```

```sh
JEKYLL_ENV=production bundle exec jekyll build
```

The tag prints nothing when there is no site id, and nothing outside the
production environment. Plain `jekyll serve` and `jekyll build` run in the
`development` environment, so your own visits while you write are never
counted. (With `queue_stub: true` it still adds the small queue stub, see
below.)

### Or let the plugin add it

If you would rather not touch your layouts (for example with a theme from a
gem), switch on automatic injection:

```yaml
privatus_analytics:
  site_id: pa_YOURSITEID
  auto_inject: true
```

After each page and post is rendered, the plugin adds the tag just before
`</head>`. It skips files that are not HTML, pages without a `<head>`, and
pages that already have the tag in their head. Static files (files without
front matter) are copied as they are, so they do not get the tag.

## Configuration

Every setting is optional except the site id.

```yaml
privatus_analytics:
  site_id: pa_YOURSITEID          # or the PRIVATUS_SITE_ID environment variable
  script_host: https://privatusstats.com # or PRIVATUS_SCRIPT_HOST
  modules: [engage, auto, vitals, clicks, ask]
  excluded_paths: [/drafts/*]
  domains: [www.example.com]
  spa: auto                       # auto, history, hash or off
  manual: false                   # true turns off the automatic pageview
  enabled_environments: [production]
  enabled:                        # true or false forces the tag on or off
  auto_inject: false
  extra_attributes:
    data-mask: /orders/*->/orders/:id
  props:
    site_section: docs
  queue_stub: false
  nonce:
```

| Setting | Default | What it does |
|---|---|---|
| `site_id` | `PRIVATUS_SITE_ID` | The `data-site` attribute. Nothing prints without it |
| `script_host` | `https://privatusstats.com` | Where `/js/pa.js` is served. Change it only if you host your own copy |
| `modules` | tracker default (`engage`) | The `data-modules` attribute. Setting it replaces the default, so keep `engage` for time on page and scroll depth. `[]` loads none |
| `excluded_paths` | none | The `data-exclude` attribute. Path patterns the tracker never counts |
| `domains` | all hosts | The `data-domains` attribute. Count only these hostnames |
| `spa` | `auto` | The `data-spa` attribute |
| `manual` | `false` | The `data-manual` attribute |
| `enabled_environments` | `[production]` | Values of `JEKYLL_ENV` that get the tag |
| `enabled` | not set | `true` or `false` forces the tag on or off in every environment |
| `auto_inject` | `false` | Adds the tag to the head of every page for you |
| `extra_attributes` | `{}` | Any other `data-*` attribute |
| `props` | `{}` | Page props sent with every pageview and event. See below |
| `queue_stub` | `false` | Prints a small script first, so `privatus.track` calls made before the tracker loads are kept and sent later |
| `nonce` | none | A Content Security Policy nonce for the tags. Static sites rarely have one |

Each tracker attribute is explained in the [script attributes
reference](https://privatusanalytics.com/docs/tracker/attributes), and the
modules in [Modules](https://privatusanalytics.com/docs/tracker/modules).

You can also override a setting for one layout or page. Lists are written with
commas:

```liquid
{% privatus_analytics modules="engage,auto" excluded_paths="/preview/*" queue_stub=true %}
```

### Development and test

Builds that are not `JEKYLL_ENV=production` do not get the tag, so your own
clicking around never reaches your reports. To see the tag while you build,
set `enabled: true` (or use a separate config file, like
`jekyll serve --config _config.yml,_config.dev.yml`). The tracker also ignores
`localhost` unless you pass `data-allow-local` or `data-debug` (see [Debug
mode](https://privatusanalytics.com/docs/tracker/debug)):

```yaml
privatus_analytics:
  enabled: true
  extra_attributes:
    data-debug: "true"
```

### Leaving people out

Use `excluded_paths` for pages you do not want counted, like drafts. The
`domains` setting makes sure only your real site is counted, not previews or
copies on other hosts.

## Product analytics: see which features people use

Privatus Analytics can show which buttons, links and forms people really use. You add a
few attributes to your HTML. The tracker reads them in the browser and sends
the events. Your build still sends nothing.

### Name events well

Use a short "Noun verb" name, like `Report exported` or `Newsletter joined`.
Put the details in props, not in the name. So write `Report exported` with
`format="csv"`, not `Report exported as CSV`. Then all exports add up in one
place, and you can split them by format.

### Events on buttons, links and forms

`{% privatus_event %}` prints the attributes inside a tag you write yourself:

```liquid
<button {% privatus_event "Report exported" format="csv" source="toolbar" %}>Export</button>
```

It prints:

```html
<button data-privatus-event="Report exported" data-privatus-prop-format="csv" data-privatus-prop-source="toolbar">Export</button>
```

Values in quotes are text. `true`, `false` and numbers stay as they are.
Anything else is read as a Liquid variable, so you can use page data:

```liquid
<a href="{{ page.pdf }}" {% privatus_event "Download started" format="pdf" guide=page.slug %}>Download</a>
```

On a form, the event is sent when the form is submitted:

```liquid
<form action="https://example.com/join" {% privatus_event "Newsletter joined" list="weekly" %}>
```

The rules:

* The name is trimmed and cut to 120 characters. An empty name prints nothing.
* Prop keys are made lowercase. Anything that is not a letter, a digit or `_`
  becomes `_`, so `report-type` becomes `report_type`. Keys are cut to 64
  characters.
* At most 30 props. Values become text: `true`, `false`, numbers as written,
  lists joined with commas. Empty (`nil`) values are left out. Values are cut
  to 500 characters.
* Everything is escaped for HTML.
* The attributes print in every environment, even when the tag is off. They do
  nothing without the tracker, so your pages look the same in development and
  production.

The tags work in HTML files and in Markdown pages, as long as they sit inside
HTML you write in the page.

### Click maps

A click map shows where people click on a page. Give the important parts a
name so they stay easy to find, even when the page changes:

```liquid
<a href="/pricing" {% privatus_click "pricing.cta" %}>See plans</a>
```

A name may use letters, digits and `_ . : -`, up to 100 characters. Anything
else prints nothing, and in development the plugin writes a warning to the
build log.

### Page props: section, version and other groups

Page props are sent with every pageview and event on the page. Use them to
split your reports by section, product, docs version or language.

Set them for the whole site in `_config.yml`:

```yaml
privatus_analytics:
  props:
    site_section: docs
    docs_version: "2.4"
```

and change them for one page in its front matter. They are merged over the site
props, and an empty value removes one:

```yaml
---
title: Getting started
privatus_props:
  section: tutorials
  docs_version:
---
```

With Jekyll's front matter defaults you can set them for a whole folder:

```yaml
defaults:
  - scope:
      path: blog
    values:
      privatus_props:
        section: blog
```

The tag then prints a small script before the tracker and points the tracker
at it:

```html
<script>window.privatusPageProps=function(){return {"site_section":"docs","section":"tutorials"}}</script>
<script defer src="https://privatusstats.com/js/pa.js" data-site="pa_YOURSITEID" data-props="privatusPageProps"></script>
```

Keys follow the same rules as event props. Numbers and true or false stay as
they are, and lists stay lists (up to 30 items). The props are escaped so they
are safe inside a script.

**Never put names, emails, user ids or anything that points to one person in
props.** Privatus Analytics counts visitors without any id. Put groups (like the section
or the plan), not people. The server also removes emails and long ids it
finds.

### Track from your own JavaScript

For things that are not a click or a submit, call the tracker from your
JavaScript, as the [JavaScript API
docs](https://privatusanalytics.com/docs/tracker/javascript-api) explain:

```js
privatus.track("Feature used", { feature: "search" })
```

If your code may run before the tracker has loaded, switch on the queue stub.
It prints a tiny script before the tracker that keeps your calls in a list and
sends them once the tracker is ready:

```yaml
privatus_analytics:
  queue_stub: true
```

or for one layout: `{% privatus_analytics queue_stub=true %}`. The stub is
added even when the tag is off (in development, with `enabled: false` or with
no site id), so your `privatus.track` calls never fail in development: they
wait in the list and are never sent. Then only the stub is added, with no
tracker and no page props. This works with the `{% privatus_analytics %}` tag
and with automatic injection (`auto_inject: true`). A page that uses both
still gets the stub only once. With the queue stub off, nothing is added when
the tag is off.

### See the results

* [Funnels](https://privatusanalytics.com/docs/features/funnels): how many
  people go from one step to the next.
* [Click maps](https://privatusanalytics.com/docs/features/click-maps): where
  people click.
* [Goals](https://privatusanalytics.com/docs/features/goals): turn an event
  into a goal to count conversions.
* [Events](https://privatusanalytics.com/docs/events): every custom event and
  its props.

## Privacy

The script sets no cookies and stores nothing in the browser. The event, click
and props tags only print HTML attributes and a small script. Keep people out
of your props and event props: no names, emails or user ids. See the [privacy
documentation](https://privatusanalytics.com/docs/privacy) for what is
collected.

If you have a privacy policy, it should say which tools handle your visitors' data. You can paste this:

> This website uses [Privatus Analytics](https://privatusanalytics.com/privacy-analytics) to count visits. It
> does not use cookies and does not follow you from one website to another. Your IP address is used for a moment
> to count visits and is never stored.

Change it to fit your site. The [privacy policy generator](https://privatusanalytics.com/tools/privacy-policy-generator)
makes a longer version with your site's name in it.

## Development

The tests run in Docker so your local Ruby does not matter:

```sh
./run-docker.sh
```

It runs the Minitest suite (with real builds of tiny Jekyll sites), RuboCop,
and `gem build`.

The `example/` folder holds a tiny site for the [conformance
tests](https://github.com/Privatus-Analytics/conformance), which open it in a
real browser with the real tracker. Run them from a copy of that repo with
`./run.sh ../jekyll`.

## Contributing

Bug reports and pull requests are welcome at
https://github.com/Privatus-Analytics/jekyll.

## License

MIT. See [LICENSE.txt](LICENSE.txt). Privatus Analytics is a product of Two
Phase LLC, Wyoming, USA.
