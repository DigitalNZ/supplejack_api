# SupplejackApi

This is a [mountable engine](http://guides.rubyonrails.org/engines.html) which provides functionality to store, index and retrieve metadata via an API.

The API is configured via the `schema.rb` file which exposes a [DSL](http://en.wikipedia.org/wiki/Domain-specific_language) for defining various aspects of your API.

## Usage

1. Create a new rails app `rails _3.2.12_ new <name>`
1. Add `gem 'supplejack_api', git: 'git@github.com:DigitalNZ/supplejack_api.git'` to Gemfile
1. Install the supplejack_api gem `bundle install`
1. Run the Supplejack API installer `bundle exec rails generate supplejack_api:install`
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

## COPYRIGHT AND LICENSING  

### MAJORITY OF SUPPLEJACK CODE - GNU GENERAL PUBLIC LICENCE, VERSION 3  

Except as indicated below, Supplejack, a tool for aggregating, searching and sharing metadata records, is Crown copyright (C) 2014, New Zealand Government. Supplejack was created by DigitalNZ at the National Library of NZ and the Department of Internal Affairs. http://digitalnz.org/supplejack  

Except as indicated below, this program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.   

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.  

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses / http://www.gnu.org/licenses/gpl-3.0.txt 

### SUPPLEJACK API SUNSPOTSESSIONPROXY  

The Supplejack API SunspotSessionProxy was authored by HeyZap (http://www.heyzap.com/) and is available at http://stdout.heyzap.com/2011/08/17/sunspot-resque-session-proxy/.
