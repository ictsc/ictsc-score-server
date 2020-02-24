class ChangePasswordSizeOfProblemEnvironmentTable < ActiveRecord::Migration[6.0]
  def change
    change_column :problem_environments, :password, :string, limit: 8192
  end
end
