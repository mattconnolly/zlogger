require "zlogger/version"

module Zlogger
  autoload :Client, "zlogger/client"
  autoload :Daemon, "zlogger/daemon"
  autoload :Reader, "zlogger/reader"

  DEFAULT_PORT = 7000
end
