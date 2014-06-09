require 'logger'
require 'rbczmq'

module Zlogger
  class Client < ::Logger
    attr :options

    def initialize(options={})
      @options = options
      super(nil)
      @logdev = LogDevice.new(self)
      @logdev.run_socket_thread
    end

    def context
      @context ||= options[:context] || ZMQ::Context.new
    end

    def queue
      @queue ||= Queue.new
    end

    def connect_address
      options[:connect_address] || options[:address] || "127.0.0.1"
    end

    def port
      options[:port] || Zlogger::DEFAULT_PORT
    end

    def name
      options[:name] || "#{File.basename(Process.argv0)}:#{Process.pid}"
    end

    class LogDevice
      attr :client

      def initialize(client)
        @client = client
      end

      def write(message)
        client.queue << message
      end

      def close()
        client.queue << self
      end

      # it is not threadsafe to access ZMQ sockets, so we only write to the logging socket from a single thread.
      def run_socket_thread
        @thread ||= Thread.new do
          begin
            socket = client.context.socket :PUSH
            socket.connect("tcp://#{client.connect_address}:#{client.port}")
            loop do
              object = client.queue.pop
              break if object == self
              message = ZMQ::Message.new
              message.addstr(client.name)
              message.addstr(object.to_s)
              socket.send_message(message)
            end
            socket.close
          rescue StandardError => e
            puts "Logging socket thread error: #{e}"
          end
        end
      end
    end
  end
end
