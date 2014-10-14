require 'rspec'
require_relative '../factor-connector-api.rb'

module Factor::Connector::Test
  def service_instance(service_name)
    Factor::Connector.get_service_manager(service_name).instance
  end
end

module Factor::Connector
  class ServiceInstance
    def eventually(&block)
      found = false
      timeout = 10
      frequency = 4.0
      pause = 1 / frequency
      count = timeout * frequency
      (0..count).each do |tick|
        any = begin
          block.call
        rescue
          false
        end

        if any
          found = true
          break
        end
        sleep pause
      end
      found
    end

    def expect_in_logs(expected_hash={})
      match = {}
      found = eventually do
        any = @logs.any? do |actual_output|
          all_equal = true
          expected_hash.each_pair do |key, expected_value|
            all_equal = false unless actual_output[key] == expected_value
          end
          match = actual_output if all_equal
          all_equal
        end
      end

      last_log = if @logs.last[:type]=='log' && @logs.last[:status]=='debug'
          @logs.select {|log| log[:type] == 'log' && log[:status]=='debug'}.first
        else
          @logs.last
        end

      raise "No match found for #{expected_hash}. Last line was #{last_log}" unless found
      match if found
    end

    def expect_return(expected_values={})
      compares = { type: 'return' }
      compares[:payload] = expected_values if expected_values && expected_values!={}
      expect_in_logs compares
    end

    def expect_fail(options={})
      expect_in_logs type: 'fail'
    end

    def expect_log(status,expected_values={})
      compares = {
        type:'log',
        status:status
      }
      compares[:message] = expected_values[:message] if expected_values[:message]
      expect_in_logs compares
    end

    def expect_info(expected_values={})
      expect_log('info',expected_values)
    end

    def expect_warn(expected_values={})
      expect_log('info',expected_values)
    end

    def expect_error(expected_values={})
      expect_log('error',expected_values)
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