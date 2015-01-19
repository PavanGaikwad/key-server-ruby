require "securerandom"
require "rufus-scheduler"


class KeyServer
	attr_reader :all_keys
	attr_reader :used_map

	
	def initialize
		@used_map = {}
		(1..60).each { |num| @used_map[num] = [] }
		@all_keys = {}
		@all_keys[:used] = []
		@all_keys[:available] = []
	end


	def generate_keys(number=10,length=10)
		number.times do 
			@all_keys[:available] << SecureRandom.hex(length).to_sym
		end
		true
	end

	def dispatch_key
		if @all_keys[:available].size > 0
			key_to_dispatch = @all_keys[:available].pop
			@all_keys[:used] << key_to_dispatch if !@all_keys[:used].include?(key_to_dispatch)
			@used_map[get_current_slot] << key_to_dispatch
			key_to_dispatch
		else
			nil
		end
	end

	def delete_key(key_to_delete, all=false)
		key_to_delete = key_to_delete.to_sym
		@all_keys[:available].delete(key_to_delete)
		@all_keys[:used].delete(key_to_delete)
		if all
			(1..60).each do |slot|
			@used_map[slot].delete(key_to_delete)
			end
		else
			((get_current_slot-5)..get_current_slot).each do |slot|
			@used_map[slot].delete(key_to_delete)
			end
		end
	end

	def unblock(key_to_unblock)
		# check if key is valid by looking at the available and used keys
		# if valid, copy the key to :avaliable key
		key_to_unblock = key_to_unblock.to_sym
		if @all_keys[:available].include?(key_to_unblock) || @all_keys[:used].include?(key_to_unblock)
			@all_keys[:available] << key_to_unblock if !@all_keys[:available].include?(key_to_unblock)
		end
	end



	def keep_alive(key_to_keep_alive)
		# check if key is in the available and the used map
		# move the key to the current slot, if present in the last 5 slots
		# move the key from :available to :used, if not already present in :used
		key_to_keep_alive = key_to_keep_alive.to_sym
		current_slot = get_current_slot

		if @all_keys[:available].include?(key_to_keep_alive) || @all_keys[:used].include?(key_to_keep_alive)
			puts "key is valid"
			((current_slot-5)...current_slot).each do |slot|
				puts "slot", slot
				if @used_map[slot].include?(key_to_keep_alive)
					puts "found key in slot", slot
					@used_map[current_slot] << key_to_keep_alive if !@used_map[current_slot].include?(key_to_keep_alive)
					@used_map[slot].delete(key_to_keep_alive)
					if @all_keys[:available].include?(key_to_keep_alive)
						@all_keys[:available].delete(key_to_keep_alive)
					end
					@all_keys[:used] << key_to_keep_alive if !@all_keys[:used].include?(key_to_keep_alive)

				end #do ends here
			end 
		end
		del_cleanup
	end

	def release_cleanup
		# check the last 5 slots excluding the current slot and move all keys to :avaliable slot, if not already present there
		collected_keys = []
		current_slot = get_current_slot
		((current_slot-5)..current_slot).each do |slot|
			collected_keys << @used_map[slot] if @used_map[slot]
		end
		collected_keys.flatten!
		collected_keys.each do |key|
			@all_keys[:available] << key if !@all_keys[:available].include?(key)
		end
	end


	def del_cleanup
		# collect all keys from all slots exceot the last 5 slots and delete them
		current_slot = get_current_slot
		collected_keys = []
		(1..(current_slot-5)).each do |slot|
			puts "del cleanup slot ",slot
			collected_keys << @used_map[slot]
		end
		collected_keys.flatten!
		collected_keys.each {|key| delete_key(key,all=true)}
	end


	def get_current_slot
		Time.new.min
	end

end


