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
There is no particulare test framework we recommend; however, you will need to know how to call the new service you defined. 

```ruby
require 'connector-api'
Dir.glob('./lib/factor/connector/*.rb').each { |f| require f }

service_manager  = Factor::Connector.get_service_manager('myservice')
service_instance = service_manager.instance

service_instance.callback = proc do |action_response|
  puts action_response
end

service_instance.call_action('list',params)

# sleep 5
```

The `get_service_manager` gets you the Service Manager for your service. Each service defined is defined as a singelton instance of ServiceManger. The call to `service_manager.instance` instantiates a new instance of ServiceInstance of your service. This is used to maintain state for this instance as you may have multiple instances with different callbacks and parameters. In other words, two different instances can have two different callbacks and execute two different actions in parallel.

The `callback` block will execute every time a new message comes in form your service. Remember how you used the methods like `info`, `fail`, `error`, and `action_callback`, well all of those are now triggering a callback. The response will be a Hash. Here is an example of one of the outputs.

    {:type=>"log", :status=>"info", :message=>"Initializing connection settings"}
    {:type=>"log", :status=>"info", :message=>"Retreiving list of servers"}
    {:type=>"return", :payload=>[{:state=>"ACTIVE", :updated=>"2014-09-30T17:15:16Z", :host_id=>"ffec79d5145436b031973879740ce2736c21d3da913deaa0bccf6561", :addresses=>{"public"=>[{"version"=>6, "addr"=>"2001:4800:7813:516:d02:b50b:5bdb:71ab"}, {"version"=>4, "addr"=>"192.237.202.61"}], "private"=>[{"version"=>4, "addr"=>"10.183.7.124"}]}, :links=>[{"href"=>"https://dfw.servers.api.rackspacecloud.com/v2/843739/servers/1d8173b8-6efc-4f40-a134-d5cff5c1fe4a", "rel"=>"self"}, {"href"=>"https://dfw.servers.api.rackspacecloud.com/843739/servers/1d8173b8-6efc-4f40-a134-d5cff5c1fe4a", "rel"=>"bookmark"}], :key_name=>"Factor", :image_id=>"34437b38-6df1-4efa-bded-f637d8864b83", :state_ext=>nil, "OS-EXT-STS:vm_state"=>"active", :flavor_id=>"3", :id=>"1d8173b8-6efc-4f40-a134-d5cff5c1fe4a", :user_id=>"10045058", :name=>"console", :created=>"2014-09-30T17:13:26Z", :tenant_id=>"843739", :disk_config=>"AUTO", :ipv4_address=>"192.237.202.61", :ipv6_address=>"2001:4800:7813:516:d02:b50b:5bdb:71ab", :progress=>100, "OS-EXT-STS:power_state"=>1, :config_drive=>""}]}


The `callback` and `call_action` methods are both asynchronous, that is, they will return immidiately. When testing you can use the [Wrong gem](https://github.com/sconover/wrong) and the `eventually` method to test for particular responses asynchronously.

