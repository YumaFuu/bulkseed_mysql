require "./lib/bulkseed_mysql.rb"
require "bundler/inline"

gemfile do
  gem "activerecord"
  gem "mysql2"
  gem "faker"
end

require "active_record"

ActiveRecord::Base.establish_connection(
  adapter:  "mysql2",
  host:     ENV["DB_HOST"],
  username: ENV["DB_USER"],
  password: ENV["DB_PASSWORD"],
)

db = "bulkseed_mysql_sample_activerecord"
con = ActiveRecord::Base.connection
con.execute "DROP DATABASE IF EXISTS #{db}"
con.execute "CREATE DATABASE IF NOT EXISTS #{db}"

ActiveRecord::Base.establish_connection(
  adapter:  "mysql2",
  host:     ENV["DB_HOST"],
  username: ENV["DB_USER"],
  password: ENV["DB_PASSWORD"],
  database: db,
)

class CreateSample < ActiveRecord::Migration[4.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :age
      t.integer :sex
      t.timestamps
    end

    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :user_id
      t.index :user_id
      t.timestamps
    end
  end
end

CreateSample.migrate :up

class User < ActiveRecord::Base
  has_many :posts
  enum sex: [:male, :female, :other]
end

class Post < ActiveRecord::Base
  belongs_to :user
end

# -----------------------------------
# Use prepare

BulkseedMysql.init(
  db_host: ENV.fetch("DB_HOST", "localhost"),
  db_user: ENV.fetch("DB_USER", "root"),
  db_password: ENV.fetch("DB_PASSWORD", "password"),
  db_name: ENV.fetch("DB_NAME", db),
)

seed = BulkseedMysql.new

now = Time.now.to_s :db
seed.prepare do |s|
  s.table = User.table_name
  s.columns = User.column_names
  s.data = [
    [1, Faker::Name.name, 31, User.sexes[:male], now, now],
    [2, Faker::Name.name, 19, User.sexes[:female], now, now],
    [3, Faker::Name.name, 21, User.sexes[:other], now, now],
    [4, Faker::Name.name, 20, User.sexes[:male], now, now],
    [5, Faker::Name.name, 46, User.sexes[:female], now, now],
    [6, Faker::Name.name, 20, User.sexes[:other], now, now],
    [7, Faker::Name.name, 38, User.sexes[:male], now, now],
    [8, Faker::Name.name, 18, User.sexes[:female], now, now],
    [9, Faker::Name.name, 28, User.sexes[:other], now, now],
  ]
end

seed.call

# -----------------------------------
# Without prepare

BulkseedMysql.call "posts" do |s|
  s.data = 1.upto(10000).map do |i|
    {
      id: i,
      user_id: (rand * 9).to_i,
      title: Faker::Book.title,
      body: Faker::Quote.matz,
    }
  end
end
