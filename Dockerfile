FROM ruby:2.6.4

RUN apt-get clean all && apt-get update -qq && apt-get install -y nodejs postgresql-client graphviz

RUN rm -rf /var/lib/apt/lists/*

# Set the root of your Rails application
ENV RAILS_ROOT /rails-app
RUN mkdir -p $RAILS_ROOT

# Set working directory to the root path of the Rails app
WORKDIR $RAILS_ROOT

# Do not install gem documentation
RUN echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

# If we copy the whole app directory, the bundle would install
# everytime an application file changed. Copying the Gemfiles first
# avoids this and installs the bundle only when the Gemfile changed.
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

RUN gem install bundler
RUN bundle install

COPY . $RAILS_ROOT

# Copy entrypoint file to container & run it
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000