#!/usr/bin/env ruby

$: << File.expand_path("../lib", __FILE__)
require "toyosql"

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
  rescue Toyosql::Error => e
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
assert_equal [[1]], "select 1"
assert_equal [[2]], "select 2"
assert_equal [[12]], "select 12"
assert_equal [[1, 2]], "select 1, 2"
assert_equal [[1], [2], [3]], "select id from people"
assert_equal [["rangai"], ["Nakano Pixy"], ["yocifico"]], "select name from people"
assert_equal [[1, "rangai"], [2, "Nakano Pixy"], [3, "yocifico"]], "select id, name from people"
assert_equal [[1, "rangai"], [2, "Nakano Pixy"], [3, "yocifico"]], "select people.id, people.name from people"
assert_equal [[1, "Blue mage"], [2, "Red mage"], [3, "White mage"]], "select id, name from jobs"
