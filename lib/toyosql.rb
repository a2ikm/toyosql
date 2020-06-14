class Toyosql
  class Error < StandardError
  end

  class SyntaxError < Error
  end

  class NameError < Error
  end
  
  

  Job = Struct.new("Job", :id, :name)
  Person = Struct.new("Person", :id, :name, :age, :email)
  Empty = Struct.new("Empty")

  def initialize
    table_path = File.expand_path("../data/tables", __dir__)
    jobs_csv = CSV.read(table_path + "/jobs.csv",{headers: true, converters: :integer})
    people_csv = CSV.read(table_path + "/people.csv",{headers: true, converters: :integer})
    @tables = {
      "jobs" => jobs_csv.map {|item| Job.new(item["id"],item["name"])},
      "people" => people_csv.map {|item| Person.new(item["id"],item["name"],item["age"],item["email"])},
      "empties" => [
        Empty.new,
      ]
    }
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
      table = @tables[stmt.from.name]
    else
      table = @tables["empties"]
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

require "CSV"
require_relative "toyosql/token"
require_relative "toyosql/node"
require_relative "toyosql/lexer"
require_relative "toyosql/parser"