module Phoenix5k 
	class Supervisor
		attr_accessor :monitors, :threads, :logger
		
		# Spawns an initial Monitor instance that will search 
		# the grid's infrastructure and isolate all the sites 
		# for 
		def initialize
			@logger = Logger.new(File.new("./logs/supervisor.log", 'w'))
			@monitors = []
			@threads = []
			@logger.info "Supervisor created"
		end

		# Starts a given Monitor
		# @param id Monitor's ID 
		# @return Nothing
		def startMon id 

		end

		# Stops a given Monitor 
		# @param id Monitor's ID 
		# @return Nothing
		def stopMon id

		end 

		# Starts all the Monitors
		def startAll
			@monitors.each do |m|
				@logger.info "Monitor #{m.id} - requesting start"
				threads << Thread.new { m.supervise_d }
			end 
		end 

		# Stops all the Monitors 
		def stopAll 
			@monitors.each do |m|
				@logger.info "Monitor #{m.id} - requesting stop"
				m.stop_d
			end 
		end

		# Print information about supervisor 
		def info 
			puts "Supervising:"
			@monitors.each do |m| 
				m.info_hash
			end
			puts "------------"
		end 

		# Report when dying
  		def do_at_exit
  			@logger.warn ("Monitor{#@id} - terminating!")
  			@logger.close
  		end

	end 
end 