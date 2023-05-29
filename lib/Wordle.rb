# frozen_string_literal: true

load "txt/words.db"
require_relative "Wordle/version"
require "wordle_runner"
require "sqlite3"


module Wordle
  class Error < StandardError; end
  # Your code goes here...

  class GameRound

    def pick_random_line
      db = SQLite3::Database.new @@db_path
      return db.execute "SELECT * FROM four ORDER BY RANDOM() LIMIT 1"

      #File.readlines( "#{__dir__ }/txt/#{@length}L.txt").sample
    end

    def initialize(len, attempts)
      @length = len
      @attempts_limit = attempts
      @@db_path = "#{__dir__}/lib/words.db"
      @answer = pick_random_line
    end

    def get_ans
      @answer
    end

    def guess(str)
      return "Well done" if str == @answer

      @attempts_limit -= 1
      return "Loh!" if @attempts_limit.zero?

      "Wrong"
    end
  end
end



db = SQLite3::Database.new "C:/Users/User/Documents/GitHub/Gem_Wordle/lib/words.db"
puts db.execute "SELECT * FROM four ORDER BY RANDOM() LIMIT 1"

