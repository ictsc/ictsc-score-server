require 'active_support/core_ext/numeric/bytes.rb'

class Attachment < ActiveRecord::Base
  validates :filename, presence: true
  validates :access_token, presence: true
  # blobのサイズ制限はバリデーションが必須
  validates :data, presence: true, length: { maximum: 20.megabyte }

  belongs_to :member

  # method: POST
  def self.allowed_to_create_by?(user = nil, action: "")
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      in_competition?
    else # nologin, ...
      false
    end
  end

  def readable?(by: nil, action: '')
    self.class.readables(user: by, action: action).exists?(id: id)
  end

  # method: GET, DELETE
  def allowed?(method:, by: nil, action: "")
    return readable?(by: by, action: action) if method == 'GET'

    case by&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      true
    when ROLE_ID[:participant]
      member_id == by.id
    else # nologin, ...
      false
    end
  end

  def self.readable_columns(user:, action: '', reference_keys: true)
    col_names = self.all_column_names(reference_keys: reference_keys)

    # dataのサイズが大きいとJSON化に失敗するからデフォルトでは返さない
    col_names -= %w(data) if action != 'download'

    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
    when ROLE_ID[:participant]
      # 参加者はaccess_tokenを後から取得できない(POST時のみ取得可能)
      col_names -= %w(access_token)
    else # nologin, viewer
      col_names = []
    end

    col_names
  end

  scope :filter_columns, ->(user:, action: '') {
    cols = readable_columns(user: user, action: action, reference_keys: false)
    next none if cols.empty?
    select(*cols)
  }

  scope :readable_records, ->(user:, action: '') {
    case user&.role_id
    when ROLE_ID[:admin], ROLE_ID[:writer]
      all
    when ROLE_ID[:participant]
      next none unless in_competition?
      where(member: user)
    else # nologin, viewer
      none
    end
  }

  # method: GET
  scope :readables, ->(user:, action: '') {
    readable_records(user: user, action: action)
      .filter_columns(user: user, action: action)
  }

  # 取得用URL
  def url
    "/api/attachments/#{id}/#{access_token}"
  end
end
