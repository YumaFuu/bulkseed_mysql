# frozen_string_literal: true
require "pry"
require "json"
require 'terminal-table'

class BulkseedMysql
  class Seed
    def inspect
      pretty_table = Terminal::Table.new do |t|
        t << @columns
        t.add_separator

        @values.each do |v|
          t << v
        end
      end

      <<~TXT
        ======= #{@table} =========
        #{ pretty_table }
      TXT
    end

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
      host: ENV["DB_HOST"],
      username: ENV["DB_USER"],
      password: ENV["DB_PASSWORD"],
      database: "bulkseed_mysql_sample"
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
      puts s.inspect
      @conn.query s.to_cmd
    end
  end
end
