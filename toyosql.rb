class Toyosql
  class SyntaxError < StandardError
  end

  Person = Struct.new(:id, :name, :age, :email)

  def initialize
    @people = [
      Person.new(1, "John Smith", 32, "john.smith@example.com"),
      Person.new(2, "Nakano Pixy", 18, "nakano.pixy@example.com"),
      Person.new(3, "yocifico", 17, "yocifico@example.com"),
    ]
  end

  def execute(sql)
    if m = sql.match(/select (\w+)/)
      select_expr = m[1]
      @people.map do |person|
        if Person.members.any? { |m| m.to_s == select_expr }
          [person[select_expr]]
        else
          [select_expr.to_i]
        end
      end
    else
      raise SyntaxError
    end
  end
end
