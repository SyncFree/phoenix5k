require 'optparse'
require 'restfully'
require 'yaml'
require 'time'
require 'logger'

module Phoenix5k
  class APIMonitor
    attr_reader :root, :session, :id, :j_hash
    attr_accessor :jobs, :logger, :supervise
    @config
    @@cnt=0

    # Constructor
    def initialize
      @id = @@cnt
      @@cnt+=1
      @supervise = false 
      @jobs = []
      @j_hash = Hash.new
      @logger = Logger.new(File.new("./logs/monitor#{id}.log", 'w'))
      @logger.level = $dbugLvl
      @logger.info "monitor{#@id} - Loading config file..." 
      #@config = YAML.load_file(File.expand_path("~/.restfully/api.grid5000.fr.yml"))
      @config = $config['r_path']
      begin 
        @logger.info "monitor{#@id} - Connecting to #{@config['uri']}" 
        @session = Restfully::Session.new(
          :username => @config['username'],
          :password => @config['password'],
          :base_uri => @config['uri']
        )
        @root = @session.root
      rescue 
        @logger.fatal "monitor{#@id} - API Unreacheable"
        puts "monitor{#@id} - API Unreacheable"
        return
      end 
    end 

    # Report when dying
    def do_at_exit
      @logger.warn ("monitor{#@id} - terminating!")
      @logger.close
    end
    
    # Find and add to supervised jobs list by jobid (1230821) or userid ("hulk").
    # "cluster" can be specified as "all" (- or nil) to iterate through whole
    # Grid infrastructure. This will obviously take much more time than skipping
    # to a specific location.
    # Otherwise a specific site can be specified to speed up the research
    #
    # It is possible to feed jobusrid an array of values, for example :
    # ['user1', 'user2', 1235432, 'user4'] , which  will return an array of
    # all the corresponding jobs, whether those are identified by jobIDs or by userIDs
    # @param cluster [String] Specific cluster (eg. "Rennes"), nil or "all"
    # @param jobusrid [Array] User IDs, Job IDs, anything goes
    # @return Updated version of @jobs array
    def fetch_jobs!(cluster, jobusrid)
      if jobusrid==nil
        @logger.fatal "At least one job or user id must be specified, aborting"
        raise "At least one job or user id must be specified, aborting"
      end
      puts "monitor{#@id} - Looking for #{jobusrid} on #{cluster}" if $dbug 
      @logger.info "Looking for #{jobusrid} on #{cluster}"
      (j_ids = [] << jobusrid).flatten! #Convert to array
      size= j_ids.length
      puts "Size : #{size} & 0 : #{j_ids[0]}"
      s_sites = ((cluster.to_s!="all") && (cluster!=nil)) ? 1 : root.sites.length
      i=0
      root.sites.each do |site|
        begin 
          next unless ((site['uid']==cluster.to_s) || (cluster.to_s == "all") || (cluster == nil))
          i+=1
          puts "monitor{#@id} - " + i.to_s+"/"+s_sites.to_s+" " + site['description'] + " connecting..." 
          @logger.info "monitor{#@id} - " + i.to_s+"/"+s_sites.to_s+" " + site['description'] + " connecting..." 
          site.jobs.each do |job|
            j_ids.each do |t_id|
              if (t_id.kind_of? Integer)
                if job['uid'].to_i==t_id
                  @logger.info "monitor{#@id} - #{t_id} found on #{site['description']}"  
                  puts "#{t_id} found on #{site['description']}" if $dbug
                  @jobs << job
                  updateHash(site['uid'], job['uid'])
                  if size == 1 # Job id is unique
                    return jobs
                  end
                end
              elsif (t_id.kind_of? String)
                if job['user'].to_s == t_id
                  @logger.info "monitor{#@id} - '#{t_id}' found on '#{site['description']}'jobid #{job['uid']}"  
                  puts "monitor{#@id} - '#{t_id}' found on '#{site['description']}' jobid #{job['uid']}" if $dbug
                  @jobs << job
                  updateHash(site['uid'], job['uid'])
                end
              else
                @logger.warn "Unknown input for #{t_id}, skipping"  
                puts "monitor{#@id} - Unknown input for #{t_id}, skipping"
              end
            end
          end
        rescue
          @logger.warn "monitor{#@id} - could not connect to '#{site['description']}'"
          puts "monitor{#@id} - could not connect to '#{site['description']}'"
        end
      end
      if jobs.length >0
        @logger.info "monitor{#@id} - scan completed"
        return jobs
      else
        @logger.warn  "#{jobusrid} not found on #{cluster}"  
        puts "monitor{#@id} - #{jobusrid} not found on #{cluster}"
        return nil
      end
    end
    
    # Print all job proprietes
    # @param job [Integer] Job ID
    # @return nothing
    def job_properties(job)
      job.properties.each do |k, v|
        puts "#{k} : #{v}"
      end
      puts ""
    end

    # Sort jobs in a hashlist by site name
    # lille : [123, 456, 789]
    # @param k [String] Site name, "lille", "rennes"
    # @param v [Integer] Job ID
    # @return nothing
    def updateHash!(k, v)
      arr= [v]
      if (@j_hash.has_key? k)
        arr = @j_hash.fetch(k)
        arr << v
      end
      @j_hash[k] = arr
    end
    

    # Report on a job status
    # @param job Job to report
    # @return nothing
    def job_report(job)
      state = job['state']
      owner = job['user']
      uid = job['uid']
      if ((state.to_s=="running") || (state.to_s=="waiting"))
        @logger.info "monitor{#@id} - #{owner} job #{uid} #{state}"
      else 
        @logger.warn "monitor{#@id} - job #{uid} #{state}"
      end
    end
    
    # Daemon to be run in thread
    # @return Nothing
    def supervise_d
      @supervise = true
      @logger.info "monitor{#@id} - Launching supervisor daemon..."
      if jobs.length > 0 
        while @supervise do
          @jobs.each do |job|
            job_report(job)
          end
          sleep(5)
        end
      else
        @logger.warn "monitor{#@id} - Not supervising any jobs"
        return
      end 
      @logger.warn "monitor{#@id} - Supervisor daemon terminated"
      return
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

    # Print supervised jobs
    # @return nothing
    def info
      print "monitor{#@id} - supervising jobs: "
      if @jobs.length==0
        puts "(Empty)"
        return
      end
      @jobs.each do |job|
        print job['uid'].to_s + " "
      end
      puts ""
    end

    # Print supervised jobs grouped by sites
    def info_hash
      puts "monitor{#@id} - jobs statuses: "
      @j_hash.each do |key, value|
        puts "#{key} : #{value}"
      end
      puts "-------------------------------"
    end

    def self.eq? m
      return false if !(m.is_a? Monitor)
      return true if self.id == m.id
    end     

  end #Class
end
