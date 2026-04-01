require 'net/http'
require 'uri'
require 'json'

class GapAnalysisService
  MODEL = "gemini-2.5-flash"

  def initialize(api_key, resume_text, job_description)
    @api_key = api_key
    @resume_text = resume_text
    @job_description = job_description
  end

  def generate
    return nil if @resume_text.blank? || @job_description.blank?
    raise ArgumentError, "API Key is missing" if @api_key.blank?

    prompt = <<~PROMPT
      You are an expert HR recruiter and technical interviewer.
      Current Date Context: Today is #{Date.today.strftime('%B %Y')}. Do NOT treat dates up to this year as being in the future.
      I will provide you with a candidate's resume and a job description.
      Your task is to analyze the candidate's resume against the exact requirements, skills, and qualifications listed in the job description.
      Identify what is MISSING from the resume (the "gaps") or what could be improved to increase the candidate's likelihood of being hired.
      Provide a highly actionable, constructive, and concise gap analysis.
      
      Format your response as a direct list of actionable bullet points, focusing only on the gaps and how to bridge them. Do not include introductory or concluding fluff. Keep it concise but detailed.
      Language: Match the language of the job description. If the job description is in Portuguese, write in Portuguese.

      ### JOB DESCRIPTION:
      #{@job_description}

      ### CANDIDATE RESUME:
      #{@resume_text}
    PROMPT

    uri = URI("https://generativelanguage.googleapis.com/v1beta/models/#{MODEL}:generateContent?key=#{@api_key}")
    request = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
    request.body = {
      contents: [
        { parts: [{ text: prompt }] }
      ]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    parsed_response = JSON.parse(response.body)

    if !response.is_a?(Net::HTTPSuccess)
      error_msg = parsed_response.dig("error", "message") || response.body
      Rails.logger.error("[GapAnalysisService] Gemini error: #{error_msg}")
      raise "Gemini API Error: #{error_msg}"
    end

    analysis = parsed_response.dig("candidates", 0, "content", "parts", 0, "text")
    raise "Gemini returned no text" if analysis.nil?

    analysis
  rescue => e
    Rails.logger.error("[GapAnalysisService] Error: #{e.message}")
    raise
  end
end
