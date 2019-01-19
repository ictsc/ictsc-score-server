require 'active_support'
require 'active_support/core_ext/numeric/bytes'

class SquashedSchema < ActiveRecord::Migration[5.2]
  def change
    create_table "answers" do |t|
      t.string     "text",       null: false, limit: 4095
      t.references :problem,     null: false
      t.references :team,        null: false
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
    end

    create_table "attachments" do |t|
      t.string     "filename",     null: false
      t.string     "access_token", null: false
      t.binary     "data",         null: false, limit: 20.megabyte
      t.references :member,        null: false
      t.datetime   "created_at",   null: false
      t.datetime   "updated_at",   null: false
    end

    create_table "comments" do |t|
      t.string     "text",       null: false, limit: 4095
      t.references :member,      null: false
      t.references :commentable, null: false, polymorphic: true
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
    end

    create_table "first_correct_answers" do |t|
      t.references :answer,      null: false
      t.references :problem,     null: false
      t.references :team,        null: false
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
      t.index      ["team_id", "problem_id"], name: "index_first_correct_answers_on_team_id_and_problem_id", unique: true
    end

    create_table "issues" do |t|
      t.string     "title",      null: false
      t.boolean    "closed",     null: false, default: false
      t.references :problem,     null: false
      t.references :team,        null: false
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
    end

    create_table "members" do |t|
      t.string     "name",            null: false
      t.string     "login",           null: false
      t.string     "hashed_password", null: false
      t.references :team,             null: true
      t.references :role,             null: false
      t.datetime   "created_at",      null: false
      t.datetime   "updated_at",      null: false
      t.index      ["login"],         name: "index_members_on_login", unique: true
    end

    create_table "notices" do |t|
      t.string     "title",      null: false
      t.string     "text",       null: false, limit: 4095
      t.boolean    "pinned",     null: false, default: false
      t.references :member,      null: false
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
    end

    create_table "notification_subscribers" do |t|
      t.string     "channel_id",  null: false
      t.references :subscribable, null: false, polymorphic: true, index: { name: "index_notification_subscribers_on_subscribable", unique: true } # NOTE: index name length limit is 64
      t.datetime   "created_at",  null: false
      t.datetime   "updated_at",  null: false
    end

    create_table "problem_groups" do |t|
      t.string   "name",                   null: false
      t.string   "description",            null: false, default: '', limit: 4095
      t.boolean  "visible",                null: false, default: true
      t.integer  "completing_bonus_point", null: false, default: 0
      t.string   "icon_url",               null: true,  limit: 4095
      t.integer  "order",                  null: false, default: 0
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
    end

    create_table "problem_groups_problems" do |t|
      t.references :problem,       null: false
      t.references :problem_group, null: false
      t.datetime   "created_at",   null: false
      t.datetime   "updated_at",   null: false
      t.index      ["problem_id",  "problem_group_id"], name: "index_problem_groups_problems_on_problem_id_and_problem_group_id", unique: true
    end

    create_table "problems" do |t|
      t.string     "title",                    null: false
      t.string     "text",                     null: false, limit: 4095
      t.integer    "reference_point",          null: false
      t.integer    "perfect_point",            null: false
      t.boolean    "team_private",             null: false, default: false
      t.integer    "order",                    null: false, default: 0
      t.string     "secret_text",              null: false, default: "",   limit: 4095
      t.references :creator,                   null: false
      t.references :problem_must_solve_before, null: true
      t.datetime   "created_at",               null: false
      t.datetime   "updated_at",               null: false
    end

    create_table "roles" do |t|
      t.string   "name",       null: false
      t.integer  "rank",       null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index    ["name"],     name: "index_roles_on_name", unique: true
    end

    create_table "scores" do |t|
      t.integer    "point",      null: false
      t.boolean    "solved",     null: false, default: false
      t.references :answer,      null: false, index: { unique: true }
      t.references :marker,      null: false
      t.datetime   "created_at", null: false
      t.datetime   "updated_at", null: false
    end

    create_table "teams" do |t|
      t.string   "name",                       null: false
      t.string   "organization",               null: true
      t.string   "hashed_registration_code",   null: false
      t.datetime "created_at",                 null: false
      t.datetime "updated_at",                 null: false
      t.index    ["hashed_registration_code"], name: "index_teams_on_hashed_registration_code", unique: true
    end
  end
end
