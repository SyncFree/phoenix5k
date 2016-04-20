     require 'net/ssh/gateway'

     module Phoenix5k
     	class AntidoteMonitor
     		@supervise=false 
     		# Pings all antidote instances
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

     		# Periodically pings antidote and reports
     		# @param [Int] freq Refresh rate in seconds 
     		def heartbeat freq 
     			while @supervise 
     				ping
     			end
     		end

     		# Stops the supervision daemon 
    		# @return Nothing 
    		def stop_d 
    			@supervise = false
    		end 

		    # Stops and kills supervision
		    def stopKill
		      self.stop_d
		      return
		    end

     	end # Class
     end