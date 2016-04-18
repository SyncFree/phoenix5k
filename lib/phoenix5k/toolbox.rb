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
	end
end
