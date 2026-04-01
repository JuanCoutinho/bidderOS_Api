user = User.last
require 'net/http'
require 'uri'
require 'json'

def test_model(key, model_name)
  uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{model_name}:embedContent?key=#{key}")
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = { model: "models/#{model_name}", content: { parts: [{ text: "Test" }] } }.to_json
  res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
  parsed = JSON.parse(res.body)
  if res.is_a?(Net::HTTPSuccess)
    puts "#{model_name} SUCCESS, SIZE: #{parsed.dig('embedding', 'values').size}"
  else
    puts "#{model_name} ERROR: #{parsed.dig('error', 'message')}"
  end
end

test_model(user.gemini_api_key, "embedding-001")
test_model(user.gemini_api_key, "text-embedding-004")
