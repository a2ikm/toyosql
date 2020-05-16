class Toyosql
  class Error < StandardError
  end

  class SyntaxError < Error
  end

  class NameError < Error
  end

  Person = Struct.new("Person", :id, :name, :age, :email)
  Empty = Struct.new("Empty")

  def initialize
    @people = [
      Person.new(1, "John Smith", 32, "john.smith@example.com"),
      Person.new(2, "Nakano Pixy", 18, "nakano.pixy@example.com"),
      Person.new(3, "yocifico", 17, "yocifico@example.com"),
    ]
    @empties = [Empty.new]
  end

  def execute(sql)
    tokens = Lexer.new(sql).lex
    stmt = Parser.new(tokens).parse

    case stmt.type
    when :select_stmt
      execute_select(stmt)
    else
      raise SyntaxError, "unknown statement `#{stmt.type}`"
    end
  end

  def execute_select(stmt)
    if stmt.from
      table = @people
    else
      table = @empties
    end

    table.map do |row|
      stmt.select_exprs.map do |select_expr|
        case select_expr.type
        when :column_name
          if row.class.members.any? { |m| m.to_s == select_expr.name }
            row[select_expr.name]
          else
            raise NameError, "unknown column `#{select_expr.name}``"
          end
        when :number
          select_expr.value
        else
          raise SyntaxError, "unrecognized expression `#{select_expr.type}``"
        end
      end
    end
  end
end

require_relative "toyosql/token"
require_relative "toyosql/node"
require_relative "toyosql/lexer"
require_relative "toyosql/parser"
