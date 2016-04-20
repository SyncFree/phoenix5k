# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    require f
  end
end

# Cleans up on interruption and at the end of execution 
def cleanup!
  @logger.warn "Received cleanup request, killing all jobs and deployments..."
  #DEPLOYMENTS.each{|deployment| deployment.delete}
  #JOBS.each{|job| job.delete}
end

# Run cleanup! on sigint or sigterm
%w{INT TERM}.each do |signal|
  Signal.trap(signal){
    cleanup!
    exit(1)
  }
end

module Phoenix5k
  require         "phoenix5k/version"
  require         "phoenix5k/toolbox"
  require_all     "phoenix5k/deploy"
  require_all     "phoenix5k/supervisor"
  $dbugLvl        = Logger::DEBUG
  $dbug           = 1
  @logger         = Logger.new(File.new("./logs/phoenix5k.log", 'w'))
  @logger.info    "Phoenix5k initialized"
  $antidote_path  = "/home/mike/psar/antidote/dev/dev*"
  #"for d in /home/mike/psar/antidote/dev/dev*; do $d/bin/antidote ping; done"
end
