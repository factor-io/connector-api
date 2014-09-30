# encoding: UTF-8

Dir.glob('./lib/definitions/*.rb') { |p| require p }
Dir.glob('./lib/builders/*.rb') { |p| require p }
require_relative './instances/service_instance.rb'
# require 'instances/service_instance'

module Factor
  module Connector
    class ServiceManager
      attr_accessor :definition

      def service(id, &block)
        @definition = Factor::Connector::ServiceBuilder.new(id, &block).build
      end

      def instance
        instance = Factor::Connector::ServiceInstance.new(definition: @definition)
        instance
      end

      def self.load(filename)
        dsl = new
        dsl.instance_eval(File.read(filename))
        dsl
      end
    end
  end
end
