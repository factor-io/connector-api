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

### Factor::Connector.service(id)
This is the top-level definition of a new service. It takes a string ID and a block. The string ID is the ID you will use to address this service. The ID is used by the connector service to generate a URL like /v0.4/:myservice. When defining the connector.yml file in your workflow directory, it will use this URL to reference the specific service.

### action
`action` and `listener` are the two highest level capabilities within a service definition. An action is a method you call to take an action. It is short lived and ephemeral, like sending a message to Hipchat.

### action_callback
An action callback is what you run when the action is done processing. It takes one variable, a hash or an array. That information becomes available in the workflow for the proceeding steps.

### listener
The `listener` is one of two of the high level capabilities within a service. It is designed to be long-living and waiting for events. For example, listening for a particulare message in a chat room, or a listener for a Github push event, or a timer which triggers every 5 mintues. Each of these live for a long time, but then trigger on a particular event.

### start_workflow
A `start_workflow` event only appears within the `listener` block. You can call it multiple times. A better name for it might be "trigger", as it triggers the execution of a workflow.

### start
The 'start' block within a listener is used to perform any work and start the listening event. For example, it may call into Github and register a post-receive web hook.

The params are all the parameters that the user passed into the call, plus the credentials from the credentials.yml file for this particular service.

    start do |params|
      # setup the listener
    end

### stop
The stop block is responsible for tearing down anything that was created by the start block. For example, if you registered a web hook with `start`, use this to unregister. The "params" passed in will be the same values you received in the "start" block.

  stop do |params|
    # tear down the artifacts created by start
  end

### web_hook

### logging - info, warn, error
You can use info, warn, and error, to send a log message. This will appear in the output of the workflow as it is executing.

    info "All is good"
    warn "There is a problem, but the workflow is still running fine"
    error "Somethings busted"

### fail
Using `fail`
