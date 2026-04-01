class ResumeProcessorService
  SUPPORTED_EXTENSIONS = %w[.pdf .docx .doc].freeze

  def initialize(user, file_path, original_filename)
    @user = user
    @file_path = file_path
    @original_filename = original_filename
    @extension = File.extname(original_filename).downcase
    @embedding_service = EmbeddingService.new(user.gemini_api_key)
  end

  def call
    unless SUPPORTED_EXTENSIONS.include?(@extension)
      raise "Unsupported file type '#{@extension}'. Only PDF and DOCX are allowed."
    end

    text = extract_text_from_file

    if text.blank?
      raise "We couldn't read the text in this file. It might be scanned (an image), password-protected, or corrupted. Please try another PDF or a DOCX file."
    end

    embedding = @embedding_service.generate(text)

    @user.resumes.create!(
      filename: @original_filename,
      content_text: text,
      embedding: embedding
    )
  end

  private

  def extract_text_from_file
    case @extension
    when '.pdf'
      extract_pdf
    when '.docx', '.doc'
      extract_docx
    end
  end

  def extract_pdf
    reader = PDF::Reader.new(@file_path)
    reader.pages.map(&:text).join("\n").strip
  rescue => e
    Rails.logger.error("[ResumeProcessorService] PDF extraction error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    ""
  end

  def extract_docx
    doc = Docx::Document.open(@file_path)
    doc.paragraphs.map(&:to_s).join("\n").strip
  rescue => e
    Rails.logger.error("[ResumeProcessorService] DOCX extraction error: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    ""
  end
end