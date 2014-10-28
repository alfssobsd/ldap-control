require "resque/tasks"
Resque.logger = Logger.new STDOUT
Resque.logger.level = Logger::DEBUG
task "resque:setup" => :environment