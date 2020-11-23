# frozen_string_literal: true

class Team < ApplicationRecord
  # PlasmaでSSEする際にlistenするチャンネル
  # 認証の代わりに推測困難なIDを使う
  has_secure_token :channel
  # create時に生成されるためバリデーション無効
  validates :channel, presence: true, on: :update

  validates :role,            presence: true
  validates :beginner,        boolean:  true
  validates :number,          presence: true, uniqueness: true
  validates :name,            presence: true, uniqueness: true
  # dummy field
  validates :password,        presence: true, length: { maximum: ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED }, if: :will_save_change_to_password_digest?
  validates :password_digest, presence: true
  validates :organization,    allow_empty: true
  validates :color,           presence: true, color_code: true
  validates :secret_text,     allow_empty: true

  has_many :answers,               dependent: :destroy
  has_many :penalties,             dependent: :destroy
  has_many :attachments,           dependent: :destroy
  has_many :first_correct_answers, dependent: :destroy # NOTE: JANOG47 NETCON では使用せず
  has_many :issues,                dependent: :destroy
  has_many :notices,               dependent: :destroy
  has_many :environments,          dependent: :destroy, class_name: 'ProblemEnvironment'

  # 値が大きいほど大体権限が高い
  enum role: {
    staff: 10,
    audience: 5,
    player: 1
  }

  after_commit :delete_session, on: %i[update], if: :saved_change_to_password_digest?

  attr_reader :password

  def delete_session
    Session.destroy_by(team_id: id)
  end

  def password=(value)
    return if value.blank?

    @password = value
    self.password_digest = BCrypt::Password.create(@password, cost: self.class.password_hash_cost)
  end

  def authenticate(plain_password)
    BCrypt::Password.new(password_digest).is_password?(plain_password) && self
  end

  # greater than or equal roles
  def gte_roles
    Team.roles.select {|_k, v| v >= self.role_before_type_cast }.keys
  end

  # less than or equal roles
  def lte_roles
    Team.roles.select {|_k, v| v <= self.role_before_type_cast }.keys
  end

  def team99?
    name == Team.special_team_name_team99
  end

  class << self
    def password_hash_cost
      # test時は速度を優先
      Rails.env.test? ? 1 : BCrypt::Engine.cost
    end

    def special_team_name_staff
      'staff'
    end

    def special_team_name_team99
      'team99'
    end

    def login(name:, password:)
      # ハッシュ計算は重いため計算を始める前にコネクションをリリースする
      Team
        .find_by(name: name)
        .tap { connection_pool.release_connection }
        &.authenticate(password)
    end

    def player_without_team99
      # team99は毎回使われる特殊チーム
      player.where.not(name: special_team_name_team99)
    end

    # デバッグ用ショートハンド
    def number(number)
      self.find_by(number: number)
    end
  end
end
