class AddGeminiApiKeyToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :gemini_api_key, :string
  end
end
