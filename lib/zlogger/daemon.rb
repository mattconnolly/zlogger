require 'rbczmq'
require 'date'
require 'pathname'

module Zlogger
  class Daemon

    FLUSH_TIMER = 0.1 # flush the log to disk after this many seconds.

    attr :options
    attr_accessor :output_file
    attr_accessor :log_date

    def initialize(options={})
      @options = options
      if options[:output]
        @log_date = Date.today
        @output_file = File.new(output_filepath, 'a+')
      end
    end

    def run
      socket = context.socket :SUB
      socket.subscribe ""
      socket.bind("tcp://#{bind_address}:#{port}")

      poll_item = ZMQ::Pollitem(socket, ZMQ::POLLIN)
      poller = ZMQ::Poller.new
      poller.register(poll_item)

      loop do
        begin
          rotate_file if options[:rotate]

          poller.poll(FLUSH_TIMER)
          if poller.readables.include?(socket)
            message = socket.recv_message
            prefix = message.pop.to_s
            buffer = message.pop.to_s
            buffer.gsub("\r\n", "\n")
            buffer.split("\n").each do |line|
              log(prefix, line)
            end
          end

          flush

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
      output_file || $stdout
    end

    def output_filepath
      filename = options[:output]
      file_extension = File.extname(filename)
      filename = filename.gsub(file_extension, "") unless file_extension == ""
      if options[:rotate]
        filename = "#{ filename }_#{ log_date.to_s }.log"
      else
        filename = "#{ filename }.log"
      end
      Pathname.new(filename).to_s
    end

    def rotate_file
      if self.log_date < Date.today

        self.log_date = Date.today

        # closes previous day file
        self.output_file.close if output_file # just a fail safe in case that for some reason the output file is nil

        # assigns file for the new day to output_file attribute
        self.output_file = File.new(output_filepath, 'a+')
      end
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
      $stdout.puts(formatted) if options[:stdout] && options[:output]
      pub_socket.send(formatted)
    end

    # flush the output file only if enough elapsed time has occurred since the last flush. We want the log capture to
    # be responsive, and reduce the amount of time waiting for synchronous disk i/o.
    def flush
      if output
        now = Time.now
        if @last_flush.nil? || (now - @last_flush > FLUSH_TIMER)
          output.flush
          @last_flush = now
        end
      end
    end
  end
end
