require_relative 'models/insta_notes'
system "clear"
puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\nInstaNotes\n%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n\n"
instanotes = InstaNotes.new
puts instanotes.notes
puts instanotes.new_list
