[![Code Climate](https://codeclimate.com/github/factor-io/connector-api/badges/gpa.svg)](https://codeclimate.com/github/factor-io/connector-api)
[![Test Coverage](https://codeclimate.com/github/factor-io/connector-api/badges/coverage.svg)](https://codeclimate.com/github/factor-io/connector-api)
[![Dependency Status](https://gemnasium.com/factor-io/connector-api.svg)](https://gemnasium.com/factor-io/connector-api)
[![Build Status](https://travis-ci.org/factor-io/connector-api.svg)](https://travis-ci.org/factor-io/connector-api)
[![Gem Version](https://badge.fury.io/rb/factor-connector-api.svg)](http://badge.fury.io/rb/factor-connector-api)

Connector API
=============

The Connector API is a Ruby gem you use to create custom connectors for the Factor.io Connector. Connectors like like [Github](https://github.com/factor-io/connector-github), [Heroku](https://github.com/factor-io/connector-heroku), [Rackspace](https://github.com/factor-io/connector-rackspace), and [Hipchat](https://github.com/factor-io/connector-hipchat) were built using this gem. This readme will help you create a custom connector.

# Building a custom Connector
Each Connector ships as a Ruby Gem which gets included in the Connector app to host the integration. Each of these gems can contain one or more services to integrate. For example, [Rackspace](https://github.com/factor-io/connector-rackspace) has numerous files in [/lib/factor/connector](https://github.com/factor-io/connector-rackspace/tree/master/lib/factor/connector).


## Base
For the sake of example we'll call this service "myservice". Start by creating a new repo in Github. You can call it `factor-connector-myservice`. Next, we need to have at least these three files.

### factor-connector-myservice.gemspec
This integration to "myservice" is going to be bundled as a Ruby gem, and therefore we need a `.gemspec` file.

    # encoding: UTF-8
    $LOAD_PATH.push File.expand_path('../lib', __FILE__)

    Gem::Specification.new do |s|
      s.name          = 'factor-connector-myservice'
      s.version       = '0.0.3'
      s.platform      = Gem::Platform::RUBY
      s.authors       = ['Maciej Skierkowski']
      s.email         = ['maciej@factor.io']
      s.homepage      = 'https://factor.io'
      s.summary       = 'My Service Factor.io Connector'
      s.files         = Dir.glob('lib/factor/connector/*.rb')

      s.require_paths = ['lib']

      s.add_runtime_dependency 'factor-connector-api', '~> 0.0.3'
      s.add_runtime_dependency 'fog', '~> 1.23.0'
    end

One of the most important lines is `s.add_runtime_dependency 'factor-connector-api', '~> 0.0.3'` as it ensures that the Connector API is loaded. Other than that, include any other gems your app may need.

### Gemfile
Since we are delivering this as a Gem all the dependencies are defined in our gemspec file.

    source "https://rubygems.org"
    gemspec



### lib/factor/connector/myservice.rb

    require 'factor-connector-api'

    Factor::Connector.service 'myservice' do
      action 'hello' do
        name = params['name']

        fail 'Name (name) is required' unless name
        fail 'Name (name) must be a string' unless name.is_a?(String)

        info "Sending response to #{name}"

        action_callback hello_world:name
      end

      listener 'sometimes' do
        start do |params|
          info "Going to randomly start every 0-60 seconds"
          do
            sleep rand 60
            start_workflow time: Time.now.to_s
          while true
        end
        stop do |params|
          info "Stopping. KTHXBYE"
        end
      end
    end

## Building, Push, and Use
The above example is fully functional. You can build and push the gem like so.

    gem build factor-connector-myservice.gemspec
    gem push factor-connector-myservice-0.0.1.gem

To use this gem you need to go into your Connector service and do the following:
1. Add `gem 'factor-connector-myservice'` to the connector Gemfile.
2. Run `bundle install`
3. Add `require 'factor/connector/myservice` to `init.rb`
4. If you added multiple files to /lib/factor/connector/ in this gem, you'll need to to repeat #3 for each of those.

## The Connector API
More here: [https://github.com/factor-io/connector-api/wiki/Connector-API-DSL](https://github.com/factor-io/connector-api/wiki/Connector-API-DSL)


## Testing
For testing we recommend using RSpec. As an example, check out the [Rackspace connector](https://github.com/factor-io/connector-rackspace).

Here is an example spec.

````ruby
require 'spec_helper'

describe 'Compute' do
  it 'can list servers' do

    username = ENV['RACKSPACE_USERNAME']
    api_key  = ENV['RACKSPACE_API_KEY']

    service_instance = service_instance('rackspace_compute')

    params = {
      'username' => username,
      'api_key' => api_key,
      'region' => 'dfw'
    }

    service_instance.test_action('list',params) do
      expect_info message:"Retreiving list of servers"
      expect_return
    end

  end
end
````

There are a few key methods provided by `factor-connector-api/test` to use in your specs.

### test_action(method,params={})
This is a method on ServiceInstance which takes the method name, parameters, and a block. The method refers to the acion you want to call. The parameters are the ones that get passed into your action call. The block should include the provided tests to validate the type of responses.

### expect_return
This ensures that your action called `action_callback`

### expect_info, expect_warn, expect_error
These three methods react to calls for `info`, `warn`, and `error` respecively. You can also (optionally) pass in {message: 'test message'}, to check that a particulare message was generated by the service connector.

### expect_fail
This is similar to expect_return except in this case we are testing that `fail` was called in your connector and execution was stopped. This is great for negeative test cases.