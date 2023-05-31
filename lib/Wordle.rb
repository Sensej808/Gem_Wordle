# frozen_string_literal: true

require_relative "Wordle/version"
require "wordle_runner"
require "sqlite3"

module Wordle
  class WordleError < StandardError; end
  # Your code goes here...
  class WrongAttemptsNumberError < WordleError; end
  class WrongLengthError < WordleError; end
  class NoMatchInDB < WordleError; end

  class GameRound
    def pick_random_line
      db = SQLite3::Database.new @@db_path
      begin
        db.execute( "SELECT * FROM '#{@length}l' ORDER BY RANDOM() LIMIT 1")[0][0]
      rescue SQLite3::SQLException
        raise WrongLengthError, "Wrong length in GameRound constructor"
      end



      # File.readlines( "#{__dir__ }/txt/#{@length}L.txt").sample
    end

    private :pick_random_line
    def initialize(len = 5, attempts = 6)
      @length = len
      raise WrongAttemptsNumberError if attempts <= 0
      @attempts = attempts
      @@db_path = "#{__dir__}/txt/words.db"
      @answer = pick_random_line
    end

    def get_ans
      @answer
    end

    def guess(str)


      raise WrongLengthError, "wrong answer length" if str.length != @answer.length

      db = SQLite3::Database.new @@db_path
      checker = db.execute("SELECT * FROM '#{@length}l' WHERE WORD='#{str}'")[0]

      raise NoMatchInDB, "there is no such word in database" if checker.nil?

      return [Array.new(str.length) { |i| [str[i], nil] }, :attempts_zero] if @attempts.zero?

      str.downcase!
      @attempts -= 1
      if str == @answer
        return [Array.new(str.length) { |i| [str[i], :green] }, :solved]
      end

      res = Array.new(str.length) { |i| [str[i], nil] }

      str.chars.each_index { |ind| res[ind][1] = :green if str[ind] == @answer[ind] }

      str.chars.each_with_index { |c, ind| res[ind][1] = :yellow if !/[#{c}]/.match(@answer).nil? && res[ind][1].nil? }

      str.chars.each_index { |ind| res[ind][1] = :grey if res[ind][1].nil? }


      return [res, :not_solved]
    end
  end
end
