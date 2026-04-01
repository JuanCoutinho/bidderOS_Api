class RecreateResumesEmbedding < ActiveRecord::Migration[6.1]
  def change
    remove_column :resumes, :embedding
    add_column :resumes, :embedding, :vector, limit: 768
  end
end
