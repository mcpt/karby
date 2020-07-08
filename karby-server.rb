require 'date'
require 'json'
require 'securerandom'
require 'sinatra'

require_relative 'karby-util.rb'

def tablify dated_files
  "<table><tr><th>Creation Date/Time</th><th>Log File</th></tr>#{dated_files.map{|f| "<tr><td>#{f.creation_date.strftime("%Y-%m-%d %H:%M:%S.%N")}</td><td><a href=\"/raw/#{f.path}\">#{f.path}</a></td></tr>"}.join("")}</table>"
end

set :bind, (ENV.include?('BIND_ADDRESS') ? ENV['BIND_ADDRESS'] : '0.0.0.0')
set :port, (ENV.include?('BIND_PORT') ? ENV['BIND_PORT'] : '4567')

configure { set :server, :puma }

not_found do
  headers "Content-Type" => "text/html"
  '<h1>404</h1>'
end

get '/' do
  aggregated = Dir["#{POST_AGGREGATION_DIR}/*.log"].map{|path| DatedFile.new(path.split("/")[-1], File::Stat.new(path).ctime)}.sort_by(&:creation_date).reverse
  parts = Dir["#{PRE_AGGREGATION_DIR}/*.log"].map{|path| DatedFile.new(path.split("/")[-1], File::Stat.new(path).ctime)}.sort_by(&:creation_date).reverse

  headers "Content-Type" => "text/html"
  body %{<style>
* {font-family: sans-serif;}
div.expandable {display: none;}
input:checked + label + div.expandable {display: block;}
table, th, td {border: 1px solid black; border-collapse: collapse;}
th, td {padding: 5px;}
</style>
<input type=\"checkbox\" id=\"aggregated\"><label for=\"aggregated\">Show Aggregated Logs</label>
<div class=\"expandable\">
  #{tablify(aggregated)}
</div>
<hr>
<input type=\"checkbox\" id=\"parts\"><label for=\"parts\">Show Log Parts</label>
<div class=\"expandable\">
  #{tablify(parts)}
</div>}.delete("\n").squeeze(" ")
end

get '/raw/*.log' do |file|
  headers "Content-Type" => "text/plain"
  
  if Dir["#{PRE_AGGREGATION_DIR}/*.log"].include?("#{PRE_AGGREGATION_DIR}/#{file}.log") then
    send_file "#{PRE_AGGREGATION_DIR}/#{file}.log"
  elsif Dir["#{POST_AGGREGATION_DIR}/*.log"].include?("#{POST_AGGREGATION_DIR}/#{file}.log") then
    send_file "#{POST_AGGREGATION_DIR}/#{file}.log"
  else
    not_found
  end
end

post '/' do
  now = Time.now

  File.open("#{PRE_AGGREGATION_DIR}/#{now.strftime("%Y-%m-%d")}_#{request.ip}_#{SecureRandom.hex}.log", 'a') do |f|
    JSON.load(request.body.read).each do |message|
      f.puts "[#{DateTime.parse(message["timestamp"]).new_offset(Time.now.strftime("%:z")).strftime("%Y-%m-%d %H:%M:%S.%N")}] #{message["message"]}"
    end
  end
  
  nil
end