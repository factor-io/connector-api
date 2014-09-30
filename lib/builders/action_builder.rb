# encoding: UTF-8

# DSL for building actions
module Factor
  module Connector
    class ActionBuilder
      def initialize(id, &block)
        @id = id.to_s
        @start = block
      end

      def build
        ad = ActionDefinition.new
        ad.id = @id
        ad.start = @start
        ad
      end
    end
  end
end