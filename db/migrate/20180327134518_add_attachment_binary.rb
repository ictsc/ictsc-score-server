require 'active_support/core_ext/numeric/bytes.rb'

class AddAttachmentBinary < ActiveRecord::Migration[5.1]
  def change
    add_column :attachments, :data, :binary, null: false, limit: 20.megabyte
  end
end
