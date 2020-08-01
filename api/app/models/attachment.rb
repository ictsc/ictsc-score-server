# frozen_string_literal: true

class Attachment < ApplicationRecord
  TOKEN_FORMAT = { with: /\A[a-zA-Z0-9]+\z/, message: 'only allows words and numbers' }.freeze

  has_secure_token :token
  validates :token,        presence: true, uniqueness: true, format: TOKEN_FORMAT, if: :validate_token?
  validates :filename,     presence: true
  validates :content_type, presence: true
  validates :data,         presence: true
  validates :size,         presence: true
  validates :team,         presence: true

  belongs_to :team

  def validate_token?
    # has_secure_tokenはcreate時に発動する

    if new_record?
      # tokenが指定されているならバリデーションする
      token.present?
    else
      # updateでは常にバリデーション
      true
    end
  end

  def token_with_ext
    token + File.extname(filename)
  end
end
