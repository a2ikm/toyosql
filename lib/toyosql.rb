class Toyosql
  class Error < StandardError
  end

  class SyntaxError < Error
  end

  class NameError < Error
  end
  
  TABLES_PATH = File.expand_path("../data/tables", __dir__)

  Empty = Struct.new("Empty")

  def read_table(table_file)
    name = File.basename(table_file, ".csv")
    rows = CSV.read(TABLES_PATH + "/" + table_file, {headers: true, converters: :integer})
    headers = rows.headers.map(&:to_sym)
    table = Struct.new(*headers, keyword_init: true)
    @tables[name] = rows.map {|row| table.new(row.to_h)}
  end

  def initialize
    files = Dir::entries(TABLES_PATH)
    files.delete(".")
    files.delete("..")
    @tables = {"empties" => [
        Empty.new,
      ]
    }
    files.map {|t| read_table(t)}
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