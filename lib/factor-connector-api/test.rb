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
    include Wrong
    
    def expect_response(options={}, &block)
      eventually options do
        @logs.any? do |log|
          block.call(log)
        end
      end
    end

    def expect_return(options={})
      expect_response(options) do |log|
        assert { log[:type] == 'return' } 
        assert { log[:payload] == log[:type] }
      end
    end

    def expect_fail(options={})
      expect_response(options) do |log|
        assert { log[:type] == 'fail' }
      end
    end

    def expect_info(options={})
      expect_response(options) do |log|
        assert { log[:type] == 'log' }
        assert { log[:status] == 'info' } if log[:type] == 'log'
        assert { log[:message] == options[:message] } if options[:message] && log[:type]=='log' && log[:status]=='info'
      end
    end

    def expect_warn(options={})
      expect_response(options) do |log|
        assert { log[:type] == 'log' }
        assert { log[:status] == 'warn' } if log[:type] == 'log'
        assert { log[:message] == options[:message] } if options[:message] && log[:type]=='log' && log[:status]=='warn'
      end
    end

    def expect_error(options={})
      expect_response(options) do |log|
        assert { log[:type] == 'log' }
        assert { log[:status] == 'error' } if log[:type] == 'log'
        assert { log[:message] == options[:message] } if options[:message] && log[:type]=='log' && log[:status]=='error'
      end
    end

    def test_action(action_name, params={}, &block)

      @logs = []
      self.callback = proc do |action_response|
        @logs << action_response
      end
      call_action(action_name,params)

      instance_exec &block
    end
  end
end