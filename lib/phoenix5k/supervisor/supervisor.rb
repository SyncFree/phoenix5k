module Phoenix5k 
	class Supervisor
		attr_accessor :monitors, :threads, :logger
		
		def initialize
			@logger = Logger.new(File.new("./logs/supervisor.log", 'w'))
			@monitors = Hash.new # Monitor -> Thread 
			@m_arr = []
			@logger.info "Supervisor created"
		end

		# Adds a monitor to supervision 
		# @param mon [Monitor] Instance of Monitor 
		# @param site [String] Search scope: "nil" for full, "lille" etc for specific site
		# @param ids [Int/String Array] What to search for, jobids, usersids
		# @return Nothing
		def addMon (mon, site, ids)
			puts "Launching job fetch for #{mon.id}"
			@m_arr << mon.fetch_jobs!(site, ids)
		end 
=begin
		# Starts a given Monitor, 
		# @param id Monitor's ID 
		# @return Nothing
		def startMon id 
			m_tmp = @monitors.select { |m| m.id = id } 
			if m_tmp.empty?
				@logger.warn "Monitor#{m_tmp.id} does not exist"
				return
			end
			@monitors[m_tmp] = Thread.new { m_tmp.supervise_d }
		end

		# Stops a given Monitor 
		# @param id Monitor's ID 
		# @return Nothing
		def stopMon id
			m_tmp = @monitors.select { |m| m.id = id } 
			if m_tmp.empty?
				@logger.warn "Monitor#{m_tmp.id} does not exist"
				return
			end 
			@monitors[m_tmp] = Thread.new { m_tmp.supervise_d }
		end
=end
		# Starts all the Monitors
		def startAll
			if @m_arr.empty?
				@logger.warn "No monitors listed - nothing to start"
				return
			end
			@m_arr.each do |m|
				@logger.info "Monitor #{m.id} - requesting start"
				@monitors[m]=Thread.new { m.supervise_d }
				puts "Thread #{@monitors[m]} started !"
			end
		end 

		# Stops all the Monitors
		def stopAll
			if @m_arr.empty?
				@logger.warn "No monitors listed - nothing to stop"
				return
			end
			@m_arr.each do |m, v|
				@logger.info "Monitor #{m.id} - requesting stop"
				m.stop_d
			end
		end

		# Stops and kills all the Monitors 
		def killAll 
			if @monitors.empty?
				@logger.warn "No monitors listed - nothing to start"
				return
			end
			@monitors.each do |m, v|
				m.stopKill 
				v.join
			end
		end 

		# Print information about supervisor 
		def info 
			puts "Supervising:"
			@m_arr.each do |m|
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