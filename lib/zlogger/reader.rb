require 'rbczmq'

module Zlogger
  class Reader
    attr :options

    def initialize(options={})
      @options = options
    end

    def sub_socket
      @sub_socket ||=
          begin
            socket = context.socket :SUB
            socket.subscribe ""
            puts "connecting to: tcp://#{address}:#{port}"
            socket.connect("tcp://#{address}:#{port}")
            socket
          end
    end

    def context
      @context ||= (ZMQ.context || ZMQ::Context.new)
    end

    def port
      options[:port] ||= DEFAULT_PORT + 1
    end

    def address
      options[:address] ||= "0.0.0.0"
    end

    def run
      begin
        loop do
          puts sub_socket.recv
        end
      rescue Interrupt
        # exit nicely
      end
    end
  end
end
