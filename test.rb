#!/usr/bin/env ruby

require_relative "toyosql"

def toyosql(sql)
  Toyosql.new.execute(sql)
end

def assert_equal(expected, sql)
  actual = toyosql(sql)
  if actual != expected
    c = caller(1, 1).first
    abort "#{c}: expected #{expected.inspect} but got #{actual.inspect}"
  end
end

def assert_raise(klass, sql)
  begin
    toyosql(sql)
  rescue => e
    if e.is_a?(klass)
      return
    else
      c = caller(2, 1).first
      abort "#{c}: expected raising #{klass} but raised #{e.class} (#{e.message})"
    end
  end
  c = caller(1, 1).first
  abort "#{c}: expected raising #{klass} but nothing raised"
end

assert_raise Toyosql::SyntaxError, "select"
assert_equal [1], "select 1"
assert_equal [2], "select 2"
