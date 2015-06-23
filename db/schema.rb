# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150623165703) do

  create_table "attribution_days", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.date     "date"
    t.float    "performance"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_holdings", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "day_id"
    t.float    "performance"
    t.float    "contribution"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "attribution_portfolios", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "axys_system_companies", force: :cascade do |t|
    t.string   "cusip"
    t.string   "ticker"
    t.string   "code"
    t.string   "name"
    t.string   "security"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "axys_system_holdings", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.integer  "company_id"
    t.integer  "bmv_holding_id"
    t.integer  "emv_holding_id"
    t.date     "date"
    t.float    "quantity"
    t.float    "unit_cost"
    t.float    "total_cost"
    t.float    "price"
    t.float    "market_value"
    t.float    "pct_assets"
    t.float    "yield"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "axys_system_holdings_reports", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.date     "date"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "axys_system_portfolios", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "axys_system_transactions", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.integer  "company_id"
    t.integer  "holding_id"
    t.date     "date"
    t.string   "code"
    t.string   "security"
    t.string   "close_method"
    t.string   "lot"
    t.date     "trade_date"
    t.date     "settle_date"
    t.string   "sd_type"
    t.string   "sd_symbol"
    t.float    "quantity"
    t.float    "trade_amount"
    t.string   "cusip"
    t.string   "symbol"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "axys_system_transactions_reports", force: :cascade do |t|
    t.integer  "portfolio_id"
    t.date     "date"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "holidays", force: :cascade do |t|
    t.integer  "year"
    t.integer  "month"
    t.integer  "day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
