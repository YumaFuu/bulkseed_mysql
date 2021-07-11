# frozen_string_literal: true
require_relative "./bulkseed_mysql/version"
require "json"

class BulkseedMysql
  class Seed
    attr_accessor :table, :columns ,:values

    def initialize(table)
      @table = table
      @values = []
    end

    def data= data
      data.each do |item|
        case item
        when Array
          @values << item
        when Hash
          @columns ||= item.keys

          if @columns != item.keys
            raise <<~TXT
              Keys are not same to before
              table: #{@table}
              row: #{JSON.pretty_generate(item)}
            TXT
          end

          @values << item.values
        end
      end
    end

    def to_cmd
      if @columns.nil?
        raise "You have to specify columns"
      end

      values = @values.map do |rows|
        vals = rows.map do |v|
          # escape quotes
          s = %Q(#{v}).gsub('"', '\"')
          v.nil? ? "NULL" : "\"#{s}\""
        end

        "(#{ vals * "," })"
      end

      <<~SQL
        REPLACE INTO #{@table}
        (#{ @columns.map{ |a| %(`#{a}`) } * ',' })
        VALUES
        #{ values * "," }
      SQL
    end
  end

  def self.init(
    db_host: nil,
    db_user: nil,
    db_password: nil,
    db_name: nil,
    db_connection: Mysql2::Client.new(
      host: db_host,
      username: db_user,
      password: db_password,
      database: db_name,
    ),
    db_execute_command: :query
  )
    @@db_connection = db_connection
    @@db_cmd = db_execute_command
  end

  def self.call(name = nil, conn = nil, &block)
    seed = new conn
    seed.prepare name, &block
    seed.call
  end

  def initialize(conn = nil)
    @conn = @@db_connection
    @seeds = []
  end

  def prepare(name = nil, &block)
    seed = Seed.new name
    yield seed

    @seeds << seed
  end

  def call
    @seeds.each do |s|
      @conn.send @@db_cmd, s.to_cmd

      puts " -- #{s.table}  :  created "\
        "#{ s.values.count } rows"
    end
  end
end
