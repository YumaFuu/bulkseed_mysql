# BulkseedMysql

Bulkinsert or update using [REPLACE Statement](https://dev.mysql.com/doc/refman/5.6/en/replace.html) for mysql

If call without primary key, mysql will do DELETE and INSERT<br>
<br>
Be Carefull!!

## Installation

```ruby
# gem "mysql2"
gem "bulkseed_mysql"
```

or

```bash
# gem install mysql2
$ gem install bulkseed_mysql
```

## Usage

```ruby
require "bulkseed_mysql"

# Setup
BulkseedMysql.init(
  db_host: "host",
  db_user: "user",
  db_password: "password",
  db_name: "database",
)

# or

class SomeDatabaseConnection
  def query(sql)
    # ...
  end
end

BulkseedMysql.init(
  db_connection: SomeDatabaseConnection.new,
)
```

```ruby

now = Time.now.to_s.split(" ").take(2) * " "
# => "2021-07-09 22:14:59"

seed = BulkseedMysql.new

seed.prepare "users" do |s|
  s.columns = [:id, :name, :sex, :created_at, :updated_at]
  s.data = [
    [1, "hoge", 23, :male, now, now],
    [2, "fuga", 25, :female, now, now],
    [3, "piyo", 18, :other, now, now],
  ]
end

seed.prepare do |s|
  # you can also specify here
  s.table = "admins"

  # you can also set Array of Hash to data
  # keys are to be columns
  s.data = [
    {
      id: 1,
      name: "foo",
      email: "admin1@sample.com",
      created_at: now,
      updated_at: now,
    },
    {
      id: 2,
      name: "bar",
      email: "admin2@sample.com",
      created_at: now,
      updated_at: now,
    },
  ]
end

# insert all prepared tables
seed.call
```

```ruby
# You can call without prepare
BulkseedMysql.call "users" do |s|
  s.data = [
    ...
  ]
end

```

## Samples

[with active_record](./sample/activerecord.rb)
