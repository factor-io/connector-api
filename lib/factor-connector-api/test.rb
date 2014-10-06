require 'rspec'
require 'wrong'
require_relative '../factor-connector-api.rb'

module Factor::Connector::Test
  def service_instance(service_name)
    Factor::Connector.get_service_manager(service_name).instance
  end
end

module Factor::Connector
  class ServiceInstance
    include RSpec
    
    def expect_response(options={}, &block)
      Wrong::eventually options do
        @logs.any? do |log|
          block.call(log)
        end
      end
    end

    def expect_return(options={})
      expect_response(options) do |log|
        log[:type]=='return' && log[:payload]
      end
    end

    def expect_fail(options={})
      expect_response(options) do |log|
        log[:type]=='fail'
      end
    end

    def expect_info(options={})
      expect_response(options) do |log|
        logs_present = log[:type]=='log' && log[:status]=='info'
        options[:message] ? log[:message] == options[:message] : logs_present
      end
    end

    def expect_warn(options={})
      expect_response(options) do |log|
        logs_present = log[:type]=='log' && log[:status]=='warn'
        options[:message] ? log[:message] == options[:message] : logs_present
      end
    end

    def expect_error(options={})
      expect_response(options) do |log|
        logs_present = log[:type]=='log' && log[:status]=='error'
        options[:message] ? log[:message] == options[:message] : logs_present
      end
    end

    def test_action(action_name, params={}, &block)

      @logs = []
      self.callback = proc do |action_response|
        @logs << action_response
      end
      call_action('list',params)

      instance_exec &block
    end
  end
end