require 'rbczmq'

module Zlogger
  class Daemon

    attr :options

    def initialize(options={})
      @options = options
    end

    def run
      socket = context.socket :PULL
      socket.bind("tcp://#{bind_address}:#{port}")

      loop do
        begin
          message = socket.recv_message
          prefix = message.pop.to_s
          buffer = message.pop.to_s
          buffer.gsub("\r\n", "\n")
          buffer.split("\n").each do |line|
            log(prefix, line)
          end
        rescue Interrupt
          break
        rescue StandardError => e
          log("ZLOGGER::DAEMON", e.to_s)
        end
      end
    end

    def context
      options[:context] ||= ZMQ::Context.new
    end

    def port
      options[:port] ||= DEFAULT_PORT
    end

    def bind_address
      options[:bind_address] ||= "0.0.0.0"
    end

    def output
      options[:output] || $stdout
    end

    def log(prefix, line)
      output.puts("#{Time.now.strftime("%Y%m%d %I:%M:%S.%L")}\t#{prefix}:\t#{line}")
    end
  end
end
