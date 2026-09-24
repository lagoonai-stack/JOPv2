# syntax=docker/dockerfile:1
# Production image: minimal, multi-stage, Ruby from .ruby-version
ARG RUBY_VERSION=3.4.3
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 libvips postgresql-client && \
    ln -sf /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Production environment variables
# ENV RAILS_ENV=production \
#     BUNDLE_DEPLOYMENT=1 \
#     BUNDLE_PATH=/usr/local/bundle \
#     BUNDLE_WITHOUT=development:test \
#     LD_PRELOAD=/usr/local/lib/libjemalloc.so

# Build stage: install all gem groups so the image can run with development gems (e.g. in docker-compose)
FROM base AS build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Override base's BUNDLE_WITHOUT so development/test gems are installed in the image
ENV BUNDLE_JOBS=4
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .
RUN bundle exec bootsnap precompile -j 1 --gemfile && \
    bundle exec bootsnap precompile -j 1 app/ lib/ && \
    SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Runtime stage
FROM base
RUN groupadd --system --gid 1000 rails && \
    useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash rails
USER 1000:1000

COPY --chown=rails:rails --from=build /usr/local/bundle /usr/local/bundle
COPY --chown=rails:rails --from=build /rails /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
