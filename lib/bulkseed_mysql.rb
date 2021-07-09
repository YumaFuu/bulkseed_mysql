# frozen_string_literal: true
require "json"

class BulkseedMysql
  class Seed
    attr_reader :table, :values

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

    def columns= columns
      @columns = columns
    end

    def table= table
      @table = table
    end

    def to_cmd
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
        VALUES #{ values * "," }
      SQL
    end
  end

  def self.init(
    db_host:,
    db_user:,
    db_password:,
    db_name:
  )
    @@db_config = {
      host: db_host,
      user: db_user,
      password: db_password,
      database: db_name,
    }
  end

  def self.call(name = nil, conn = nil, &block)
    seed = new conn
    seed.prepare name, &block
    seed.call
  end

  attr_reader :seeds
  attr_accessor :conn

  def initialize(conn = nil)
    @conn = conn
    @conn ||= Mysql2::Client.new(
      host: @@db_config[:host],
      username: @@db_config[:user],
      password: @@db_config[:password],
      database: @@db_config[:database],
    )

    @seeds = []
  end

  def prepare(name = nil, &block)
    seed = Seed.new name
    yield seed

    @seeds << seed
  end

  def call
    @seeds.each do |s|
      puts " -- #{s.table}  :  created "\
        "#{ s.values.count } rows"

      @conn.query s.to_cmd
    end
  end
end
