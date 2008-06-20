require 'multilife'

if ARGV[0] == "multilife"
  m = Multilife.new
elsif ARGV[0] == "monolife"
  m = Monolife.new
end
m.run unless m.nil?
