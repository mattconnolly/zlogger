# Zlogger - A distributed logging daemon.

This gem provides a daemon that reads log messages from a ZeroMQ socket. Messages are formatted and output to STDOUT.

## Installation

Add this line to your application's Gemfile:

    gem 'zlogger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zlogger

## Usage

To run the logging daemon:

    $ zlogger

And you when messages are sent to the logger, they will appear in STDOUT formatted with the senders name prefixed to
each line.

The daemon uses two ZeroMQ sockets:

 * At the bind_address : port => a PULL socket to receive log messages.
 * At the bind_address : port + 1 => a PUB socket where re-formatted lines of the log are sent to.

To use the logging client in a Ruby process:

    require 'zlogger'

    logger = Zlogger::Client.new
    logger.debug "log this debug message"

The `logger` client object behaves like a standard ruby Logger.


## Contributing

1. Fork it ( https://github.com/[my-github-username]/zlogger/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
