class Toyosql
  class SyntaxError < StandardError
  end

  def execute(sql)
    if m = sql.match(/select (\d+)/)
      return [m[1].to_i]
    else
      raise SyntaxError
    end
  end
end
