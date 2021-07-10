# BulkseedMysql

## Installation

```ruby
gem 'bulkseed_mysql'
```

Or

```bash
$ gem install bulkseed_mysql
```

## Usage

Use REPLACE Statement. [see](https://dev.mysql.com/doc/refman/5.6/en/replace.html)<br>
If call without primary key, mysql will do DELETE and INSERT<br>
<br>
Be Carefull!!

```ruby
require "bulkseed_mysql"

# Setup
BulkseedMysql.init(
  db_host: "host",
  db_user: "user",
  db_password: "password",
  db_name: "database",
)
```

```ruby

now = Time.now.to_s.split(" ").take(2).join(" ")
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
require "bulkseed_mysql"

# You can call without prepare
BulkseedMysql.call "users" do |s|
  s.data = [
    ...
  ]
end

```

## Samples

[with active_record](./sample/activerecord.rb)
