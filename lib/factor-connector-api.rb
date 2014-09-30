require_relative './service_manager.rb'

module Factor
  module Connector
    @@service_managers={}

    def self.load(filename)
      service_manager = Factor::Connector::ServiceManager.load(filename)
      service_id      = service_manager.definition.id
      @@service_managers[service_id] = service_manager
    end

    def self.service(id, &block)
      service_manager = Factor::Connector::ServiceManager.new
      service_manager.service(id,&block)
      @@service_managers[id] = service_manager
    end

    def self.get_service_manager(service_id)
      @@service_managers[service_id]
    end

  end
end
