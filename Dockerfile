FROM ruby:3.1.2-alpine

ARG bundle_without=""
ARG rails_env="development"
ENV SECRET_KEY_BASE=abc123
RUN apk update \
      && apk add \
      openssl \
      tar \
      build-base \
      tzdata \
      postgresql-dev \
      postgresql-client \
      && mkdir -p /var/app

ENV BUNDLE_PATH=/gems BUNDLE_JOBS=4 RAILS_ENV=${rails_env} BUNDLE_WITHOUT=${bundle_without}

COPY . /var/app
WORKDIR /var/app

RUN bundle install \
      && rm -rf /gems/cache/*.gem \
      && find /gems/ -name "*.c" -delete \
      && find /gems/ -name "*.o" -delete

ENV RAILS_LOG_TO_STDOUT=true

EXPOSE 3000

CMD bin/rails s -b 0.0.0.0
