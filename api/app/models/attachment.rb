# frozen_string_literal: true

class Attachment < ApplicationRecord
  has_secure_token :token
  # create時に生成されるためバリデーション無効
  validates :token,        presence: true, on: :update
  validates :filename,     presence: true
  validates :content_type, presence: true
  validates :data,         presence: true
  validates :size,         presence: true
  validates :team,         presence: true

  belongs_to :team

  def token_with_ext
    token + File.extname(filename)
  end
end
