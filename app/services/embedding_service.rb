require 'net/http'
require 'uri'
require 'json'

class EmbeddingService
  MODEL = "gemini-embedding-001"
  DIMENSIONS = 768

  def initialize(api_key)
    @api_key = api_key
  end

  def generate(text)
    raise ArgumentError, "Text cannot be blank" if text.blank?
    raise ArgumentError, "API Key is missing" if @api_key.blank?

    truncated = truncate_text(text)

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:embedContent?key=#{@api_key}")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      model: "models/#{MODEL}",
      content: {
        parts: [{ text: truncated }]
      },
      outputDimensionality: DIMENSIONS
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    parsed_response = JSON.parse(response.body)

    if !response.is_a?(Net::HTTPSuccess)
      error_msg = parsed_response.dig("error", "message") || response.body
      Rails.logger.error("[EmbeddingService] Gemini error: #{error_msg}")
      raise "Gemini API Error: #{error_msg}"
    end

    embedding = parsed_response.dig("embedding", "values")
    raise "Gemini returned no embedding data" if embedding.nil?

    embedding
  rescue => e
    Rails.logger.error("[EmbeddingService] Error: #{e.message}")
    raise
  end

  private

  def truncate_text(text, max_tokens: 8000)
    words = text.split
    words.first(max_tokens).join(" ")
  end
end
