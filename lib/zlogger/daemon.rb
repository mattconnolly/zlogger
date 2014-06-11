require 'rbczmq'

module Zlogger
  class Daemon

    attr :options

    def initialize(options={})
      @options = options
    end

    def run
      socket = context.socket :SUB
      socket.subscribe ""
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
      @context ||= (ZMQ.context || ZMQ::Context.new)
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

    def pub_socket
      @pub_socket ||= begin
        socket = context.socket :PUB
        socket.bind("tcp://#{bind_address}:#{port.to_i + 1}")
        socket
      end
    end

    def log(prefix, line)
      formatted = "#{Time.now.strftime("%Y%m%d %I:%M:%S.%L")}\t#{prefix}:\t#{line}"
      output.puts(formatted)
      pub_socket.send(formatted)
    end
  end
end
