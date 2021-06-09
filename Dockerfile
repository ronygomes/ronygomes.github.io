# Currently GitHub uses ruby-2.7.1
FROM ruby:2.6.6-buster
LABEL maintainer "Manuel Rony Gomes <rgomes.bd@gmail.com>"

# Create /blog folder and `jekyll' user & group for accessibility
RUN groupadd --gid 1000 jekyll && useradd --create-home --shell /bin/bash --gid jekyll jekyll
RUN mkdir /blog && chown -R jekyll:jekyll /blog

USER jekyll
WORKDIR /home/jekyll/

# Copy and install dependencies in image build, code will be mounted later
COPY Gemfile /home/jekyll
COPY Gemfile.lock /home/jekyll

RUN bundler install && rm Gemfile Gemfile.lock

WORKDIR /blog
EXPOSE 4000
