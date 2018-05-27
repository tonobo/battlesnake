FROM ruby:alpine

ADD . /bs
WORKDIR /bs
RUN apk add --no-cache git
RUN bundle install --path .bundle
CMD bundle exec rackup -o 0.0.0.0
