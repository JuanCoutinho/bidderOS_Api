require 'net/http'
require 'uri'
require 'json'
user = User.last
uri = URI("https://generativelanguage.googleapis.com/v1beta/models?key=#{user.gemini_api_key}")
req = Net::HTTP::Get.new(uri)
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
models = JSON.parse(res.body)['models'] || []
models.each do |m|
  puts "#{m['name']} supports #{m['supportedGenerationMethods']}"
end
