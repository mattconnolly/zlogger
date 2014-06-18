require 'rbczmq'

module Zlogger
  class Daemon
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

      loop do
        begin
          rotate_file if options[:rotate]

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
      Pathname.new('log').join(filename).to_s
    end

    def rotate_file
      if output_file || log_date < Date.today
        log_date = Date.today

        # closes previews day file
        output_file.close

        # assigns file for the new day to output_file attribute
        output_file = @output_file = File.new(output_filepath, 'a+')
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
      pub_socket.send(formatted)
    end
  end
end
