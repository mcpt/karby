require 'sinatra'

LOGS_DIR = (ENV.include?('LOGS_DIR') ? ENV['LOGS_DIR'] : './logs')

set :bind, (ENV.include?('BIND_ADDRESS') ? ENV['BIND_ADDRESS'] : '0.0.0.0')
set :port, (ENV.include?('BIND_PORT') ? ENV['BIND_PORT'] : '4567')

not_found do
  '<h1>404</h1>'
end

post '/' do
  now = Time.now

  File.open("#{LOGS_DIR}/#{request.ip}_#{now.strftime("%Y-%m-%d")}.log", 'a') do |f|
    f.puts(request.body.read)
  end
  
  nil
end
