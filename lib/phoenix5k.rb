# Require all of the Ruby files in the given directory.
#
# path - The String relative path from here to the directory.
#
# Returns nothing.
def require_all(path)
  glob = File.join(File.dirname(__FILE__), path, '*.rb')
  Dir[glob].each do |f|
    puts "Adding " +f.to_s
    require f
  end
end

module Phoenix5k
  require     "phoenix5k/version"
  require     "phoenix5k/toolbox"
  require_all "phoenix5k/deploy"
  require_all "phoenix5k/supervisor"
  $dbugLvl    = Logger::DEBUG
  $dbug       = 1
end
