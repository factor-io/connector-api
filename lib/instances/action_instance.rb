
require_relative './instance.rb'

module Factor
  module Connector
    class ActionInstance < Factor::Connector::Instance
      include Celluloid
      attr_accessor :service_id

      def start(params)
        begin
          self.instance_exec params, &@definition.start
        rescue Factor::Connector::Error => ex
          respond type:'fail', message:ex.message
          exception ex.exception,params:params if ex.exception
        rescue => ex
          respond type:'fail', message:"Couldn't run action for unexpected reason. We've been informed and looking into it."
          exception ex,params:params
        end
      end

      def action_callback(params={})
        respond type:'return', payload:params
      end

      def fail(message,params={})
        respond type:'fail', message: message
        raise Factor::Connector::Error, exception:params[:exception], message:message if !params[:throw]
      end
    end
  end
end