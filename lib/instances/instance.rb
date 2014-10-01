# encoding: UTF-8

require 'addressable/uri'
require 'rubygems/package'
require 'open-uri'
require 'fileutils'

require_relative '../errors.rb'

module Factor
  module Connector
    class Instance
      attr_accessor :definition, :callback, :instance_id

      def initialize(options = {})
        @definition = options[:definition] if options[:definition]
      end

      def callback=(block)
        @callback = block if block
      end

      def respond(params)
        @callback.call(params) if @callback
      end

      def id
        @definition.id
      end

      def info(message)
        log 'info', message
      end

      def error(message)
        log 'error', message
      end

      def warn(message)
        log 'warn', message
      end

      def debug(message)
        log 'debug', message
      end

      def log(status, message)
        respond type: 'log', status: status, message: message
      end

      protected

      def exception(ex, parameters = {})
        debug "exception: #{ex.message}"
        debug 'backtrace:'
        ex.backtrace.each do |line|
          debug "  #{line}"
        end
        debug "parameters: #{parameters}"
      end
    end
  end
end
