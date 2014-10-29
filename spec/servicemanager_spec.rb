require 'spec_helper'

describe Factor::Connector::ServiceManager do
  before do
    Factor::Connector.service 'basic' do
      action 'test' do |params|
        info "this is info"
        warn "this is a warning"
        error "this is an error"
        info "echo: #{params['echo']}"
        action_callback some_var:'has contents'
      end
      action 'fail-test-method' do |params|
        fail "this is a fail"
      end
      listener 'listen-test' do
        start do |params|
          info "this is info"
          warn 'this is a warning'
          error "this is an error"
          info "echo: #{params['echo']}"
          start_workflow some_var:'has contents'
        end
        stop do |params|

        end
      end
    end
  end
  
  it 'loads a service manager' do
    service_manager = Factor::Connector.get_service_manager('basic')
    expect(service_manager).to be_a(Factor::Connector::ServiceManager)
  end

  it 'loads a service instance' do
    service_manager = Factor::Connector.get_service_manager('basic')
    service_instance = service_manager.instance
    expect(service_instance).to be_a(Factor::Connector::ServiceInstance)
  end

  describe 'Action' do
    before do
      service_manager = Factor::Connector.get_service_manager('basic')
      @service_instance = service_manager.instance
    end

    it 'it can call an action' do
      action_call = @service_instance.call_action('test', echo:'foo')
      expect(action_call).to be_a(Factor::Connector::ActionInstance)
    end

    it 'handle all log types, test framework, and callback' do
      require_relative '../lib/factor-connector-api/test.rb'
      @service_instance.test_action 'test', 'echo'=>'foo' do
        expect_info message:'this is info'
        expect_warn message:'this is a warning'
        expect_error message:'this is an error'
        expect_info message:'echo: foo'
        expect_return some_var: 'has contents'
      end
    end

    it 'handles failures' do
      require_relative '../lib/factor-connector-api/test.rb'
      @service_instance.test_action 'fail-test-method' do
        expect_fail
      end
    end
  end

  describe 'Listener' do
    before do
      service_manager = Factor::Connector.get_service_manager('basic')
      @service_instance = service_manager.instance
    end

    it 'it can start a listener' do
      action_call = @service_instance.start_listener('listen-test', echo:'foo')
      expect(action_call).to be_a(Factor::Connector::ListenerInstance)
    end
  end
end