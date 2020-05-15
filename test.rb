#!/usr/bin/env ruby

require_relative "toyosql"

def assert_equal(expected, sql)
  actual = toyosql(sql)
  if actual != expected
    c = caller(1, 1).first
    abort "#{c}: expected #{expected.inspect} but got #{actual.inspect}"
  end
end

assert_equal [1], "select 1"
