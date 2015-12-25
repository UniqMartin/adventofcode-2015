# Advent of Code 2015 - Day 11

INPUT_PASSWORD = "hepxcrrq".freeze

module PasswordRules
  RULE_2 = /[iol]/ # forbidden characters
  RULE_3 = /([a-z])\1.*(?!\1)([a-z])\2/ # two non-overlapping different pairs

  # Checks for runs of (at least) three consecutive letters.
  def self.rule_1?(s)
    s.each_char.each_cons(3).any? { |a, b, c| a.succ == b && b.succ == c }
  end

  def self.valid?(s)
    !s[RULE_2] && s[RULE_3] && rule_1?(s)
  end
end

def advance_password(password)
  first_candidate = password.succ
  last_candidate = "z" * password.length
  (first_candidate..last_candidate).detect { |s| PasswordRules.valid?(s) }
end

def main
  password_one = advance_password(INPUT_PASSWORD)
  password_two = advance_password(password_one)

  puts "Part One: #{password_one}"
  puts "Part Two: #{password_two}"
end

main if to_s == "main"
