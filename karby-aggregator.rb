require 'fileutils'

require_relative 'karby-util.rb'

raise ArgumentError, 'No date specified.' if ARGV[0] == nil

now = Time.now

FILES = Dir["#{PRE_AGGREGATION_DIR}/#{ARGV[0]}_*.log"]

servers = Hash.new

FILES.each do |file|
  ip = /_[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+_/.match(file).to_s[1...-1]
  
  servers[ip] = [] unless servers.include?(ip)

  servers[ip] << DatedFile.new(file, File::Stat.new(file).ctime)
end

servers.each do |ip, log_parts|
  log_parts.sort_by! &:creation_date
end

servers.each do |ip, log_parts|
  File.open("#{POST_AGGREGATION_DIR}/#{ARGV[0]}_#{ip}_aggregated_#{now.strftime("%Y-%m-%d_%H-%M-%S.%N")}.log", 'a') do |f|
    log_parts.each do |log_part|
      File.open("#{log_part.path}", 'r') do |p|
        f.puts "[karby: recieved #{log_part.creation_date.strftime("%Y-%m-%d at %H:%M:%S")}]"
        f.puts p.read
      end
    end
  end
end

FileUtils.rm_f FILES if ENV['DESTROY_LOG_PARTS'] == 'TRUE'