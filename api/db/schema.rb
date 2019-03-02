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

ActiveRecord::Schema.define(version: 2019_02_19_194031) do

  create_table "answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "text", limit: 4095, null: false
    t.bigint "problem_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id", "team_id", "created_at"], name: "index_answers_on_problem_id_and_team_id_and_created_at", unique: true
    t.index ["problem_id"], name: "index_answers_on_problem_id"
    t.index ["team_id"], name: "index_answers_on_team_id"
  end

  create_table "attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "filename", null: false
    t.string "access_token", null: false
    t.binary "data", limit: 4294967295, null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_attachments_on_member_id"
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "text", limit: 4095, null: false
    t.bigint "member_id", null: false
    t.string "commentable_type", null: false
    t.bigint "commentable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["member_id"], name: "index_comments_on_member_id"
  end

  create_table "configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", limit: 4095, null: false
    t.integer "value_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_configs_on_key", unique: true
  end

  create_table "first_correct_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "answer_id", null: false
    t.bigint "problem_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_first_correct_answers_on_answer_id"
    t.index ["problem_id"], name: "index_first_correct_answers_on_problem_id"
    t.index ["team_id", "problem_id"], name: "index_first_correct_answers_on_team_id_and_problem_id", unique: true
    t.index ["team_id"], name: "index_first_correct_answers_on_team_id"
  end

  create_table "issues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.boolean "closed", default: false, null: false
    t.bigint "problem_id", null: false
    t.bigint "team_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_issues_on_problem_id"
    t.index ["team_id"], name: "index_issues_on_team_id"
  end

  create_table "members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "login", null: false
    t.string "hashed_password", null: false
    t.bigint "team_id"
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_members_on_login", unique: true
    t.index ["role_id"], name: "index_members_on_role_id"
    t.index ["team_id"], name: "index_members_on_team_id"
  end

  create_table "notices", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.string "text", limit: 4095, null: false
    t.boolean "pinned", default: false, null: false
    t.bigint "member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["member_id"], name: "index_notices_on_member_id"
  end

  create_table "notification_subscribers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "channel_id", null: false
    t.string "subscribable_type", null: false
    t.bigint "subscribable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscribable_type", "subscribable_id"], name: "index_notification_subscribers_on_subscribable", unique: true
  end

  create_table "problem_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", limit: 4095, default: "", null: false
    t.boolean "visible", default: true, null: false
    t.integer "completing_bonus_point", default: 0, null: false
    t.string "icon_url", limit: 4095
    t.integer "order", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "problem_groups_problems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "problem_id", null: false
    t.bigint "problem_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_group_id"], name: "index_problem_groups_problems_on_problem_group_id"
    t.index ["problem_id", "problem_group_id"], name: "index_problem_groups_problems_on_problem_id_and_problem_group_id", unique: true
    t.index ["problem_id"], name: "index_problem_groups_problems_on_problem_id"
  end

  create_table "problems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "title", null: false
    t.string "text", limit: 4095, null: false
    t.integer "reference_point", null: false
    t.integer "perfect_point", null: false
    t.boolean "team_private", default: false, null: false
    t.integer "order", default: 0, null: false
    t.string "secret_text", limit: 4095, default: "", null: false
    t.bigint "creator_id", null: false
    t.bigint "problem_must_solve_before_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_problems_on_creator_id"
    t.index ["problem_must_solve_before_id"], name: "index_problems_on_problem_must_solve_before_id"
  end

  create_table "roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.integer "rank", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "scores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "point", null: false
    t.boolean "solved", default: false, null: false
    t.bigint "answer_id", null: false
    t.bigint "marker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["answer_id"], name: "index_scores_on_answer_id", unique: true
    t.index ["marker_id"], name: "index_scores_on_marker_id"
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "organization"
    t.string "hashed_registration_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hashed_registration_code"], name: "index_teams_on_hashed_registration_code", unique: true
  end

end
