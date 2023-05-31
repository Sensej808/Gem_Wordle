# frozen_string_literal: true

require "test_helper"

class TestWordle < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Wordle::VERSION
  end

  def test_create_round
    Wordle::GameRound.new(4,1)
    Wordle::GameRound.new(5,2)
    Wordle::GameRound.new(6,3)
    Wordle::GameRound.new(7,4)

    assert_raises(Wordle::WrongAttemptsNumberError) {Wordle::GameRound.new(4,-1)}
    assert_raises(Wordle::WrongAttemptsNumberError) {Wordle::GameRound.new(4,0)}
    assert_raises(Wordle::WrongAttemptsNumberError) {Wordle::GameRound.new(4,0)}
    assert_raises(Wordle::WrongLengthError) {Wordle::GameRound.new(3,1)}
    assert_raises(Wordle::WrongLengthError) {Wordle::GameRound.new(8,1)}
  end

  def test_guess_method
    att  = Wordle::GameRound.new(4,2)
    ans = att.get_ans
    att_t = Wordle::GameRound.new(4,2)
    ans_t = att_t.get_ans
    while ans == ans_t or ans[0] != ans_t[1]
      att  = Wordle::GameRound.new(4,2)
      ans = att.get_ans
      att_t = Wordle::GameRound.new(4,2)
      ans_t = att_t.get_ans
    end
    refute_equal(att.guess(ans_t), [[[ans[0],:green], [ans[1],:green], [ans[2],:green], [ans[3],:green]],:solved])
    assert_equal(att.guess(ans), [[[ans[0],:green], [ans[1],:green], [ans[2],:green], [ans[3],:green]],:solved])
    assert_equal(att.guess(ans), [[[ans[0],nil], [ans[1],nil], [ans[2],nil], [ans[3],nil]],:attempts_zero])
    assert_equal(att.guess(ans_t), [[[ans_t[0],nil], [ans_t[1],nil], [ans_t[2],nil], [ans_t[3],nil]],:attempts_zero])

    assert_equal(att_t.guess(ans)[1], :not_solved)
    assert_equal(att_t.guess(ans)[0][0], [ans[0],:yellow], "#{ans}, #{ans_t}")


    assert_raises(Wordle::WrongLengthError) {att.guess("aaa")}
    assert_raises(Wordle::NoMatchInDB) {att.guess("aaaa")}


  end
end
