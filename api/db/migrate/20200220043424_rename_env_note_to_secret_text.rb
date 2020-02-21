class RenameEnvNoteToSecretText < ActiveRecord::Migration[6.0]
  def change
    rename_column :problem_environments, :note, :secret_text
  end
end
