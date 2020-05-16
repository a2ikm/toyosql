class Toyosql
  class Error < StandardError
  end

  class SyntaxError < Error
  end

  class NameError < Error
  end

  class Token
    attr_reader :type, :string

    def initialize(type, string)
      @type = type
      @string = string
    end
  end

  class Lexer
    RESERVED = %w(select).freeze

    def initialize(sql)
      @sql = sql
    end

    def lex
      @pos = 0
      tokens = []

      while @pos < @sql.length
        if whitespace?(current)
          advance
          next
        end

        if alphabet?(current)
          word = read_word
          if RESERVED.include?(word)
            tokens << Token.new(:reserved, word)
          else
            tokens << Token.new(:name, word)
          end
          next
        end

        if digit?(current)
          digits = read_digits
          tokens << Token.new(:digits, digits)
          next
        end

        raise SyntaxError, "unexpected character `#{current}``"
      end

      tokens
    end

    private

    def advance
      @pos += 1
    end

    def current
      @sql[@pos]
    end

    def peek
      @sql[@pos + 1]
    end

    def whitespace?(c)
      c && c.match?(/\A\s\z/)
    end

    def alphabet?(c)
      c && c.match?(/\A[a-z]\z/)
    end

    def read_word
      start = @pos

      while /\A\w\z/.match?(peek)
        advance
      end

      word = @sql[start..@pos]
      advance
      word
    end

    def digit?(c)
      c && c.match?(/\A\d\z/)
    end

    def read_digits
      start = @pos

      while digit?(peek)
        advance
      end

      digit = @sql[start..@pos]
      advance
      digit
    end
  end

  class Node
    attr_reader :type, :token, :name, :select_expr, :value

    def initialize(type, token, name: nil, select_expr: nil, value: nil)
      @type = type
      @token = token
      @name = name
      @select_expr = select_expr
      @value = value
    end
  end

  class Parser
    def initialize(tokens)
      @tokens = tokens
    end

    def parse
      @pos = 0

      select_stmt
    end

    private

    def advance
      @pos += 1
    end

    def current
      @tokens[@pos]
    end

    def consume(type)
      if current && current.type == type
        token = current
        advance
        token
      end
    end

    def expect_reserved(string)
      if current && current.type == :reserved && current.string == string
        token = current
        advance
        token
      else
        raise SyntaxError, "expected reseved token `#{string}` but got `#{current&.string}``"
      end
    end

    def select_stmt
      token = expect_reserved("select")
      Node.new(:select_stmt, token, select_expr: select_expr)
    end

    def select_expr
      if token = consume(:name)
        Node.new(:column_name, token, name: token.string)
      elsif token = consume(:digits)
        Node.new(:number, token, value: token.string.to_i)
      else
        raise SyntaxError, "expected string or digits but got #{current&.type} `#{current&.string}`"
      end
    end
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
    @people.map do |person|
      select_expr = stmt.select_expr
      case select_expr.type
      when :column_name
        if Person.members.any? { |m| m.to_s == select_expr.name }
          [person[select_expr.name]]
        else
          raise NameError, "unknown column `#{select_expr.name}``"
        end
      when :number
        [select_expr.value]
      else
        raise SyntaxError, "unrecognized expression `#{select_expr.type}``"
      end
    end
  end
end
