module Api
  module V1
    class ResumesController < ApplicationController
      def index
        resumes = current_user.resumes.select(:id, :filename, :created_at)
        render json: resumes, status: :ok
      end

      def create
        return render json: { error: 'Gemini API Key is missing. Please set it in your account settings.' }, status: :bad_request if current_user.gemini_api_key.blank?
        return render json: { error: 'No files sent or invalid format.' }, status: :bad_request unless params[:files].is_a?(Array)
        processed = []
        errors = []

        params[:files].each do |file|
          begin
            ResumeProcessorService.new(current_user, file.path, file.original_filename).call
            processed << file.original_filename
          rescue => e
            errors << { file: file.original_filename, reason: e.message }
          end
        end

        if errors.any? && processed.empty?
          return render json: { error: 'Oops! We had some trouble processing your files.', errors: errors }, status: :unprocessable_entity
        end

        if errors.any?
          return render json: {
            message: 'Some files were processed, but others failed.',
            processed: processed,
            errors: errors
          }, status: :multi_status
        end

        render json: { message: 'Upload completed successfully!', processed: processed }, status: :ok
      end
    end
  end
end