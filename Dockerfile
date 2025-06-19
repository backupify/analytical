FROM ubuntu:20.04

# Avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    curl \
    libxml2-dev \
    libxslt1-dev \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    autoconf \
    bison \
    libyaml-dev \
    libffi-dev \
    libgdbm-dev \
    libncurses5-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    nodejs \
    && rm -rf /var/lib/apt/lists/* 

# Install ruby-build
RUN git clone https://github.com/rbenv/ruby-build.git && \
    cd ruby-build && \
    ./install.sh && \
    cd .. && \
    rm -rf ruby-build

# Install Ruby 2.1.0
RUN ruby-build 2.1.0 /usr/local

WORKDIR /app

# Copy the Gemfiles and install gems first (for better caching)
COPY Gemfile ./

RUN gem install bundler -v '~> 1.17.3' && \
    bundle update && \
    bundle install

# Copy the rest of the application code
COPY . .
