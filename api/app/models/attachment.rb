# frozen_string_literal: true

class Attachment < ApplicationRecord
  has_secure_token :token
  validates :filename,     presence: true
  validates :content_type, presence: true
  validates :data,         presence: true
  validates :team,         presence: true

  belongs_to :team
end
