# Conformance example site (see the conformance repo's CONTRACT.md). Build with the
# package folder as the context:
#   docker build -f example/Dockerfile .
#
# A static site reads its settings when it is built, not when it is served, so the
# site id and script host are build arguments. Their defaults are the values the
# conformance suite uses.
FROM ruby:3.3-slim-bookworm AS build
ARG PRIVATUS_SITE_ID=pa_CONFORMANCE1
ARG PRIVATUS_SCRIPT_HOST=http://mock:4000
ENV PRIVATUS_SITE_ID=$PRIVATUS_SITE_ID PRIVATUS_SCRIPT_HOST=$PRIVATUS_SCRIPT_HOST JEKYLL_ENV=production
RUN apt-get update -qq && apt-get install -y -qq --no-install-recommends build-essential >/dev/null \
    && rm -rf /var/lib/apt/lists/*
COPY jekyll-privatus-analytics.gemspec LICENSE.txt README.md CHANGELOG.md /pkg/
COPY lib/ /pkg/lib/
WORKDIR /example
COPY example/Gemfile ./
RUN bundle install -j4 --quiet
COPY example/ ./
RUN sh build.sh /site

FROM nginx:1.27-alpine
COPY example/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /site /usr/share/nginx/html
EXPOSE 8080
