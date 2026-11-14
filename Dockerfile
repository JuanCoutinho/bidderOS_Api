# syntax=docker/dockerfile:1
FROM ruby:3.2.3-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      git \
      curl && \
    rm -rf /var/lib/apt/lists/*

# Set production environment
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test" \
    PORT=3000

# Install gems
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.4.20 && \
    bundle install

# Copy application code
COPY . .

# Expose default port
EXPOSE 3000

# Start server
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

