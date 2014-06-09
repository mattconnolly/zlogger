require "zlogger/version"

module Zlogger
  autoload :Daemon, "zlogger/daemon"
  autoload :Client, "zlogger/client"

  DEFAULT_PORT = 7000
end
