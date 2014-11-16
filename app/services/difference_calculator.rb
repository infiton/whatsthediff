class DifferenceCalculator
	def initialize(project)
		@project = project
	end

	def calculate_difference
		project_data = @project.project_data

		source_hash, source_dupes = build_hash_check_dupes project_data.source_list
    	target_hash, target_dupes = build_hash_check_dupes project_data.target_list

    	source_values = source_hash.keys
    	target_values = target_hash.keys

    	source_uniq = source_values - target_values
    	target_uniq = target_values - source_values

    	source_target_union = source_values & target_values

    	 if project_data.update({
    							source_dupes: source_dupes,
    							target_dupes: target_dupes,
    							source_uniq: source_uniq.map{|k| source_hash[k]},
    							target_uniq: target_uniq.map{|k| target_hash[k]},
    							source_target_union: source_target_union.map{|k| [source_hash[k],target_hash[k]]}
    							})
    	 	@project
    	 else
    	 	false
    	 end
	end

	private
		def build_hash_check_dupes arr
      		hsh = {}
      		dps = []
	
      		arr.each do |row|
        		uuid = row["uuid"]
        		#concat all hashed fields together into large hash
        		#make sure they are sorted by field name
        		bh = row.to_h.except("uuid").sort.map{|x| x[1]}.join('')
        		if hsh.has_key? bh
        	  	dps << [hsh[bh], uuid]
        		else
        	  	hsh[bh] = uuid
        		end  
      		end
      		return hsh, dps  
    	end
end