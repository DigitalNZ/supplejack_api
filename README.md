# SupplejackApi

This is a [mountable engine](http://guides.rubyonrails.org/engines.html) which provides functionality to store, index and retrieve metadata via an API.

The API is configured via the `schema.rb` file which exposes a [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) for defining various aspects of your API.

## Usage

1. Create a new rails app `rails _3.2.12_ new <name>`
1. Add `gem 'supplejack_api', git: 'https://github.com/DigitalNZ/supplejack_api.git'` to Gemfile
1. Install the supplejack_api gem `bundle install`
1. Run the Supplejack API installer `rails generate supplejack_api:install`
1. Install dependencies `bundle install`
1. See `app/supplejack_api/schema.rb` for the Schema definition
1. Start/stop Solr `rake sunspot:solr:start|stop`

## Supplejack Stack

This API is part of the Supplejack stack - comprised of the [Worker](https://github.com/DigitalNZ/supplejack_worker) and the [Manager](https://github.com/DigitalNZ/supplejack_manager). 

See the [Setting up Supplejack Stack guide](https://github.com/DigitalNZ/supplejack_api/blob/master/Setting-up-Supplejack-stack.md) for details.


## Engine Development

### Rails console

```
cd spec/dummy/
bundle exec rails console
```

### Rails server

```
cd spec/dummy/
bundle exec rails server
```

### Solr

```
bundle exec rake app:sunspot:solr:start
``` 

This will start the server based on the configuration in `config/sunspot.yml`

```
bundle exec rake app:sunspot:solr:stop
```

## Engine Testing

### Rspec Specs

From the root of the engine, run 

```
bundle exec rspec spec/
```

This uses `spec/dummy` to mount the engine into and then runs the specs.

### Cucumber Features

From the root of the engine, run

```
bundle exec cucumber features/
```

This uses a test Solr instance from `spec/dummy/solr` in order to test searching.