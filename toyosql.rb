module Toyosql
  class SyntaxError < StandardError
  end
end

def toyosql(sql)
  if m = sql.match(/select (\d+)/)
    return [m[1].to_i]
  else
    raise Toyosql::SyntaxError
  end
end
