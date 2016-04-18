module Phoenix5k 
	# One monitor per site
	# 
	class Supervisor
		attr_accessor :monitors, :threads, :logger
		
		# Spawns an initial Monitor instance that will search 
		# the grid's infrastructure and isolate all the sites 
		# for with JobID/UserID present
		def initialize
			@logger = Logger.new(File.new("./logs/supervisor.log", 'w'))
			@monitors = Hash.new # "Lille" -> jid123 jid543 etc
			@threads = []
			@logger.info "Supervisor created"
		end

		# Adds a monitor to supervision 
		def addMon mon 
			if mon.is_a? Monitor 
				monitors<<m
			else 
				@logger.warn "#{mon} - not a Monitor instance, not added"
			end 
		end 

		# Starts a given Monitor
		# @param id Monitor's ID 
		# @return Nothing
		def startMon id 
			m_tmp = @monitors.select { |m| m.id = id } 
			if m_tmp.empty?
				@logger.warn "Monitor#{m_tmp.id} does not exist"
				return
			end 
			threads << Thread.new { m_tmp.supervise_d }
		end

		# Stops a given Monitor 
		# @param id Monitor's ID 
		# @return Nothing
		def stopMon id

		end

		# Starts all the Monitors
		def startAll
			if monitors.empty?
				@logger.warn "No monitors listed - nothing to start"
				return
			end
			@monitors.each do |m|
				@logger.info "Monitor #{m.id} - requesting start"
				threads << Thread.new { m.supervise_d }
			end 
		end 

		# Stops all the Monitors 
		def stopAll
			if m_tmp.empty?
				@logger.warn "No monitors listed - nothing to stop"
				return
			end
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
  			@logger.info ("Supervisor terminating")
  			@logger.close
  		end

	end 
end 