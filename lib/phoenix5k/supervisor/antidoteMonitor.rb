     require 'net/ssh/gateway'

     module Phoenix5k
     	class AntidoteMonitor

     		def ping
     			command = "for d in #{$antidote_path}; do $d/bin/antidote ping; done"
     			deployment["nodes"].each do |host|
     				puts "Connecting to #{host} and running ping.."
     				GATEWAY.ssh(host, "root",
     					:keys => [PRIVATE_KEY], :auth_methods => ["publickey"]
     					) do |ssh|
     					puts ssh.exec!(command)
     				end
     			end
     		end

     	end # Class
     end