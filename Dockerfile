FROM ruby:2.7.1-alpine3.12

# Update available packages index and bundler
RUN apk update && \
    gem update bundler

#Using japanese on Rails console
ENV LANG ja_JP.UTF-8

# SETUP middleware required for build
# build-base        : native extension build
# mariadb-dev       : gem mysql2
# nodejs            : JavaScript runtime library
# yarn              : gem webpacker
# tzdata            : gem tzinfo-data
# imagemagick6-dev  : ImageMagick
RUN apk add --no-cache --virtual build-deps \
        build-base \
        mariadb-dev \
        nodejs \
        yarn \
        tzdata \
        imagemagick6-dev \
        less \
        git \
    && rm -rf /usr/lib/libmysqld* \
    && rm -rf /usr/bin/mysql*

RUN mkdir /sample_app
ENV APP_ROOT /sample_app
WORKDIR $APP_ROOT

# Copy Gemfile* of host to gest
COPY ./Gemfile* $APP_ROOT/

# Run bundle install
RUN bundle install --jobs=4

# Copy from source files
COPY . $APP_ROOT

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
EXPOSE 3000

# Start the main process
CMD [ "rails", "server", "-b", "0.0.0.0" ]
