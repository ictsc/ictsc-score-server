# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/numeric/bytes'

class CreateTables < ActiveRecord::Migration[5.2]
  def change # rubocop:disable Metrics/MethodLength
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :answers, id: :uuid do |t|
      t.json       'bodies',     null: false
      t.boolean    'confirming', null: false
      t.references :problem,     null: false, type: :uuid
      t.references :team,        null: false, type: :uuid
      t.timestamps               null: false
      # 同一チームが同一問題に解答を連投する問題を緩和
      t.index %i[problem_id team_id created_at], unique: true
    end

    create_table :scores, id: :uuid do |t|
      t.integer    'point',  null: true
      t.boolean    'solved', null: false
      t.references :answer,  null: false, type: :uuid, index: { unique: true }
      t.timestamps           null: false
    end

    create_table :attachments, id: :uuid do |t|
      t.string     'filename',    null: false
      t.string     'description', null: false
      t.string     'token',       null: false
      t.binary     'data',        null: false, limit: 20.megabyte
      t.references :team,         null: false, type: :uuid
      t.timestamps                null: false
    end

    create_table :configs, id: :uuid do |t|
      t.string     'key',        null: false, index: { unique: true }
      t.string     'value',      null: false, limit: 8192
      t.integer    'value_type', null: false
      t.timestamps               null: false
    end

    create_table :first_correct_answers, id: :uuid do |t|
      t.references :answer,  null: false, type: :uuid
      t.references :problem, null: false, type: :uuid
      t.references :team,    null: false, type: :uuid
      t.timestamps           null: false
      t.index %i[team_id problem_id], unique: true
    end

    create_table :issues, id: :uuid do |t|
      t.string     'title',  null: false
      t.integer    'status', null: false
      t.references :problem, null: false, type: :uuid
      t.references :team,    null: false, type: :uuid
      t.timestamps           null: false
    end

    create_table :issue_comments, id: :uuid do |t|
      t.string     'text',       null: false, limit: 8192
      t.boolean    'from_staff', null: false
      t.references :issue,       null: false, type: :uuid
      t.timestamps               null: false
    end

    create_table :notices, id: :uuid do |t|
      t.string     'title',      null: false
      t.string     'text',       null: false, limit: 8192
      t.boolean    'pinned',     null: false
      t.references :target_team, null: true, type: :uuid
      t.timestamps               null: false
    end

    create_table :categories, id: :uuid do |t|
      t.string    'code',        null: false, index: { unique: true }
      t.string    'title',       null: false
      t.string    'description', null: false, limit: 8192
      t.integer   'order',       null: false
      t.timestamps               null: false
    end

    create_table :problems, id: :uuid do |t|
      t.string     'code',            null: false, index: { unique: true }
      t.string     'writer',          null: true
      t.string     'secret_text',     null: false, limit: 8192
      t.integer    'order',           null: false
      t.boolean    'team_private',    null: false
      t.tsrange    'open_at',         null: true
      t.references :previous_problem, null: true,  type: :uuid
      t.references :category,         null: true,  type: :uuid
      t.timestamps                    null: false
    end

    create_table :problem_bodies, id: :uuid do |t|
      t.integer    'mode',          null: false
      t.string     'title',         null: false
      t.integer    'perfect_point', null: false
      t.string     'text',          null: false, limit: 8192
      t.json       'candidates',    null: true
      t.json       'corrects',      null: true
      t.references :problem,        null: true, type: :uuid
      t.timestamps                  null: false
    end

    create_table :problem_environments, id: :uuid do |t|
      t.string     'status',   null: false
      t.string     'host',     null: false
      t.string     'user',     null: false
      t.string     'password', null: false
      t.references :problem,   null: false, type: :uuid
      t.references :team,      null: false, type: :uuid
      t.timestamps             null: false
    end

    create_table :problem_supplements, id: :uuid do |t|
      t.string     'text',        null: false, limit: 8192
      t.references :problem,      null: false, type: :uuid
      t.timestamps                null: false
    end

    create_table :teams, id: :uuid do |t|
      t.integer  'role',            null: false
      t.integer  'number',          null: false, index: { unique: true }
      t.string   'name',            null: false, index: { unique: true }
      t.string   'password_digest', null: false
      t.string   'organization',    null: true
      t.string   'color',           null: true
      t.timestamps                  null: false
    end
  end
end
