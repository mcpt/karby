require 'securerandom'
require 'sinatra'

require_relative 'karby-util.rb'

set :bind, (ENV.include?('BIND_ADDRESS') ? ENV['BIND_ADDRESS'] : '0.0.0.0')
set :port, (ENV.include?('BIND_PORT') ? ENV['BIND_PORT'] : '4567')

not_found do
  '<h1>404</h1>'
end

post '/' do
  now = Time.now

  File.open("#{PRE_AGGREGATION_DIR}/#{now.strftime("%Y-%m-%d")}_#{request.ip}_#{SecureRandom.hex}.log", 'a') do |f|
    f.puts(request.body.read)
  end
  
  nil
end
