module Api
  module V1
    class RecommendationsController < ApplicationController
      def index
        job_description = params[:job_description].to_s.strip

        return render json: { error: 'job_description is required.' }, status: :bad_request if job_description.blank?
        return render json: { error: 'Gemini API Key is missing. Please set it in your account settings.' }, status: :bad_request if current_user.gemini_api_key.blank?

        embedding = EmbeddingService.new(current_user.gemini_api_key).generate(job_description)

        results = current_user.resumes
          .nearest_neighbors(:embedding, "[#{embedding.join(',')}]", distance: 'cosine')
          .limit(5)

        render json: results.map { |r|
          {
            id: r.id,
            filename: r.filename,
            created_at: r.created_at,
            score: ((1 - r.neighbor_distance) * 100).round(1)
          }
        }, status: :ok
      rescue => e
        Rails.logger.error("[RecommendationsController] #{e.message}")
        error_msg = e.message.include?('Gemini') ? e.message : 'Failed to process recommendation.'
        render json: { error: error_msg }, status: :internal_server_error
      end

      def generate_cover_letter
        resume_id = params[:resume_id]
        job_description = params[:job_description].to_s.strip

        return render json: { error: 'resume_id and job_description are required.' }, status: :bad_request if resume_id.blank? || job_description.blank?

        resume = current_user.resumes.find_by(id: resume_id)
        return render json: { error: 'Resume not found.' }, status: :not_found if resume.nil?
        return render json: { error: 'This resume has no extracted text.' }, status: :unprocessable_entity if resume.content_text.blank?
        return render json: { error: 'Gemini API Key is missing. Please set it in your account settings.' }, status: :bad_request if current_user.gemini_api_key.blank?

        letter = CoverLetterService.new(current_user.gemini_api_key, resume.content_text, job_description).generate

        render json: { cover_letter: letter }, status: :ok
      rescue => e
        Rails.logger.error("[RecommendationsController] Cover Letter Error: #{e.message}")
        error_msg = e.message.include?('Gemini') ? e.message : 'Failed to generate cover letter.'
        render json: { error: error_msg }, status: :internal_server_error
      end

      def generate_gap_analysis
        resume_id = params[:resume_id]
        job_description = params[:job_description].to_s.strip

        return render json: { error: 'resume_id and job_description are required.' }, status: :bad_request if resume_id.blank? || job_description.blank?

        resume = current_user.resumes.find_by(id: resume_id)
        return render json: { error: 'Resume not found.' }, status: :not_found if resume.nil?
        return render json: { error: 'This resume has no extracted text.' }, status: :unprocessable_entity if resume.content_text.blank?
        return render json: { error: 'Gemini API Key is missing. Please set it in your account settings.' }, status: :bad_request if current_user.gemini_api_key.blank?

        analysis = GapAnalysisService.new(current_user.gemini_api_key, resume.content_text, job_description).generate

        render json: { gap_analysis: analysis }, status: :ok
      rescue => e
        Rails.logger.error("[RecommendationsController] Gap Analysis Error: #{e.message}")
        error_msg = e.message.include?('Gemini') ? e.message : 'Failed to generate gap analysis.'
        render json: { error: error_msg }, status: :internal_server_error
      end
    end
  end
end
