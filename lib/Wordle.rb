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
    private def grey(s)
      "\e[37m#{s}\e[0m"
    end
    private def green(s)
      "\e[32m#{s}\e[0m"
    end
    private def yellow(s)
      "\e[33m#{s}\e[0m"
    end
    private def red(s)
      "\e[31m#{s}\e[0m"
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
      puts red("YOU LOSE") if @attempts.zero?
      return [Array.new(str.length) { |i| [str[i], nil] }, :attempts_zero] if @attempts.zero?
      str.downcase!
      @attempts -= 1
      if str == @answer
        puts (green(str))
        puts (green("YOU WIN"))
        return [Array.new(str.length) { |i| [str[i], :green] }, :solved]
      end

      marker = Array.new(str.length, false)
      res = Array.new(str.length) { |i| [str[i], nil] }

      str.chars.each_index do |ind|
        if str[ind] == @answer[ind]
          res[ind][1] = :green
          marker[ind] = true
        end
      end

      str.chars.each_with_index { |c, ind| res[ind][1] = :yellow  if !@answer.index(/[#{c}]/).nil? && res[ind][1].nil?  && marker[@answer.index(/[#{c}]/)] == false }

      str.chars.each_index { |ind| res[ind][1] = :grey if res[ind][1].nil? }
      str_res = ""
      for i in res
        if i[1] == :grey
          str_res += grey(i[0])
        end
        if i[1] == :yellow
          str_res += yellow(i[0])
        end
        if i[1] == :green
          str_res += green(i[0])
        end
      end
      puts str_res
      return [res, :not_solved]
    end
  end
end
