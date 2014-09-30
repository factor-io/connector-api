require 'celluloid'

require 'definitions/action_definition'
require 'definitions/listener_definition'
require 'definitions/service_definition'
require 'definitions/web_hook_definition'

require 'builders/action_builder'
require 'builders/listener_builder'
require 'builders/service_builder'
require 'builders/web_hook_builder'

require 'instances/instance'
require 'instances/action_instance'
require 'instances/listener_instance'

module Factor
  module Connector
    class ServiceInstance < Factor::Connector::Instance
      attr_accessor :definition, :step_data, :callback, :listener_instances, :action_instances

      def initialize(options = {})
        @listener_instances = {}
        @action_instances   = {}
        @instance_id        = SecureRandom.hex
        super(options)
      end

      def call_hook(listener_id,hook_id,data,request,response)
        listener_instance = @listener_instances[listener_id]
        listener_instance.async.call_web_hook(hook_id,data,request,response)
      end

      def call_action(action_id,params)
        action_instance = ActionInstance.new
        action_instance.service_id  = self.id
        action_instance.instance_id = @instance_id
        action_instance.definition  = @definition.actions[action_id]
        action_instance.callback    = @callback
        action_instances[action_id] = action_instance
        action_instance.async.start(params)
      end

      def start_listener(listener_id,params)
        listener_instance = ListenerInstance.new
        listener_instance.service_id  = self.id
        listener_instance.instance_id = @instance_id
        listener_instance.definition  = @definition.listeners[listener_id]
        listener_instance.callback    = @callback
        @listener_instances[listener_id]=listener_instance
        listener_instance.async.start(params)
      end

      def stop_listener(listener_id)
        if !@listener_instances[listener_id]
          warn "Listener isn't running, no need to stop"
          respond type:'stopped'
        else
          @listener_instances[listener_id].stop
          @listener_instances[listener_id].terminate
          @listener_instances.delete listener_id
        end
      end

      def stop_action(action_id)
        if @action_instances[action_id]
          @action_instances[action_id].terminate
          @action_instances.delete action_id
        end
      end

      def has_action?(action_id)
        @definition.actions.include?(action_id)
      end

      def has_listener?(listener_id)
        @definition.listeners.include?(listener_id)
      end
    end
  end
end