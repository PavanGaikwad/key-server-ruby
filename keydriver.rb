require_relative "key-server"
k = KeyServer.new
k.generate_keys
scheduler = Rufus::Scheduler.new

scheduler.every("5m") do
  puts "keep alive cleanup in progress."
  k.del_cleanup
end

scheduler.every("1m") do
  puts "release cleanup in progress."
  k.release_cleanup
end

while true
  print ">> "
  cmd = gets.chomp
  case cmd
  when "dispatch" then puts k.dispatch_key
  when "display" then puts k.used_map
  when "all" then puts k.all_keys
  when "delete" then
    print "enter key >> "
    key = gets.chomp
    k.delete_key(key)
  when "unblock" then
    print "enter key >> "
    key = gets.chomp
    if k.unblock_key(key)
      puts "Unblocked #{key}"
    else
      puts "Unblock failed for key : #{key}"
    end
  when "keep" then
    print "enter key >> "
    key = gets.chomp
    k.keep_alive(key)

  else puts "did not understand."
  end
end
