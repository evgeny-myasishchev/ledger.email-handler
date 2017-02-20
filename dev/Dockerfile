FROM ruby:2.3

# rsyslog is used to test logging
RUN apt-get update && apt-get install -y \
  rsyslog \
  build-essential \
  locales \
  vim
  
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LC_ALL=en_US.UTF-8


COPY Gemfile Gemfile.lock dev/docker-entrypoint.sh ./
RUN gem install bundler && bundle install --jobs 20 --retry 5

VOLUME /project
WORKDIR /project
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
