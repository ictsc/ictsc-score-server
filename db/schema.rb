# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170301053432) do

  create_table "answers", force: :cascade do |t|
    t.integer  "problem_id",                 null: false
    t.integer  "team_id",                    null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "completed",  default: false, null: false
    t.index ["id"], name: "index_answers_on_id", unique: true
    t.index ["team_id"], name: "index_answers_on_team_id"
  end

  create_table "attachments", force: :cascade do |t|
    t.string   "filename",   null: false
    t.integer  "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_attachments_on_id", unique: true
    t.index ["member_id"], name: "index_attachments_on_member_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string   "text",             limit: 4000, null: false
    t.integer  "member_id",                     null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "commentable_type",              null: false
    t.integer  "commentable_id",                null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "title",                      null: false
    t.boolean  "closed",     default: false, null: false
    t.integer  "problem_id",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "team_id",                    null: false
    t.index ["id"], name: "index_issues_on_id", unique: true
  end

  create_table "members", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "login",           null: false
    t.string   "hashed_password", null: false
    t.integer  "team_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "role_id"
    t.index ["id"], name: "index_members_on_id", unique: true
    t.index ["login"], name: "index_members_on_login", unique: true
  end

  create_table "notices", force: :cascade do |t|
    t.string   "title",                      null: false
    t.string   "text",                       null: false
    t.boolean  "pinned",     default: false, null: false
    t.integer  "member_id",                  null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["id"], name: "index_notices_on_id", unique: true
    t.index ["member_id"], name: "index_notices_on_member_id"
  end

  create_table "problem_groups", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["id"], name: "index_problem_groups_on_id", unique: true
  end

  create_table "problems", force: :cascade do |t|
    t.string   "title",                                     null: false
    t.string   "text",                         limit: 1000, null: false
    t.integer  "creator_id",                                null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "problem_must_solve_before_id"
    t.integer  "reference_point"
    t.integer  "perfect_point"
    t.integer  "problem_group_id"
    t.index ["id"], name: "index_problems_on_id", unique: true
    t.index ["problem_group_id"], name: "index_problems_on_problem_group_id"
    t.index ["problem_must_solve_before_id"], name: "index_problems_on_problem_must_solve_before_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "rank",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "scores", force: :cascade do |t|
    t.integer  "point",      null: false
    t.integer  "answer_id",  null: false
    t.integer  "marker_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_scores_on_answer_id", unique: true
    t.index ["id"], name: "index_scores_on_id", unique: true
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",                           null: false
    t.string   "organization"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "registration_code", default: "", null: false
    t.index ["id"], name: "index_teams_on_id", unique: true
  end

end
