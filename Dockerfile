FROM ruby:3.0.2
RUN apt-get update && apt-get install -y \
  build-essential

RUN mkdir /app
WORKDIR /app
COPY . .
RUN gem install bundler && bundle install --jobs 20 --retry 5
RUN rake install
CMD ["bash"]
