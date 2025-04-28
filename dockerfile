# Use the official Ruby image as the base
FROM ruby:3.2.1

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set the working directory
WORKDIR /app

# Copy the Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install Ruby gems
RUN bundle install
RUN bundle _2.5.19_ install

# Copy the rest of the application code
COPY . .

# Expose port 3001
EXPOSE 3000

# Start the Rails server
# CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3001"]
CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
