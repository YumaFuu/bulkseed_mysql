require "./lib/bulkseed_mysql.rb"
require "bundler/inline"

gemfile do
  gem "activerecord"
  gem "mysql2"
end

require "active_record"

ActiveRecord::Base.establish_connection(
  adapter:  "mysql2",
  host:     ENV["DB_HOST"],
  username: ENV["DB_USER"],
  password: ENV["DB_PASSWORD"],
)

db = "bulkseed_mysql_sample"
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
      t.string :body
      t.integer :user_id
      t.index :user_id
      t.timestamps
    end
  end
end

CreateSample.migrate :up

class User < ActiveRecord::Base
  enum sex: [:male, :female, :other]
end

class Post < ActiveRecord::Base
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
seed.conn = ActiveRecord::Base.connection

now = Time.now.to_s :db
seed.prepare do |s|
  s.table = User.table_name
  s.columns = User.column_names
  s.data = [
    [1, "aaa", 23, User.sexes[:male], now, now],
    [2, "bbb", 18, User.sexes[:female], now, now],
    [3, "ccc", 18, User.sexes[:other], now, now],
  ]
end

seed.call

# -----------------------------------
# Without prepare

BulkseedMysql.call "posts" do |s|
  s.data = [
    {
      id: 1,
      user_id: 1,
      title: "user1-1",
      body: "body1",
    },
    {
      id: 2,
      user_id: 1,
      title: "user1-2",
      body: "body2",
    },
    {
      id: 3,
      user_id: 2,
      title: "user2-1",
      body: "body3",
    },
    {
      id: 4,
      user_id: 3,
      title: "user3-1",
      body: "body4",
    },
  ]
end
