module Phoenix5k
	class Toolbox 
		# Sort jobs in a hashlist by site name
	    # lille : [123, 456, 789]
	    # @param k [String] Site name, "lille", "rennes"
	    # @param v [Integer] Job ID
	    # @return nothing, modifies <hash>
	    def updateHash!(hash, k, v)
	    	arr= [v]
	    	if (hash.has_key? k)
	    		arr = hash.fetch(k)
	    		arr << v
	    	end
	    	hash[k] = arr
	    end

		# Reads Restfully's configuration 
		#
		# @return Configuration array
		def readConfig 
			return YAML.load_file(File.expand_path("~/.restfully/api.grid5000.fr.yml"))
		end

		# Connects to Grid API 
		# @param conf [YAML Array] Configuration
		# @return API Session Object
		def connect conf
			begin
				session = Restfully::Session.new(
					:username => conf['username'],
					:password => conf['password'],
					:base_uri => conf['uri']
					)
				return session.root
			rescue 
				@logger.fatal "monitor{#@id} - API Unreacheable"
				puts "monitor{#@id} - API Unreacheable"
				return
			end
		end

	end
end
