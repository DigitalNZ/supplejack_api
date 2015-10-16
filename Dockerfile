FROM ruby:2.1.7

ENV HOME /app
RUN mkdir $HOME

WORKDIR $HOME
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD supplejack_api.gemspec supplejack_api.gemspec
RUN bundle install

ADD . .

ENTRYPOINT bundle exec rspec
