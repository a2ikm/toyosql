class Toyosql
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

    def consume_reserved(string)
      if current && current.type == :reserved && current.string == string
        token = current
        advance
        token
      end
    end

    def expect(type)
      if current && current.type == type
        token = current
        advance
        token
      else
        raise SyntaxError, "expected token type `#{type}` but got `#{current&.type}``"
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

      select_exprs = []
      select_exprs << select_expr
      while consume_reserved(",")
        select_exprs << select_expr
      end

      from = nil
      if consume_reserved("from")
        from = table_reference
      end

      Node.new(:select_stmt, token, select_exprs: select_exprs, from: from)
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

    def table_reference
      token = expect(:name)
      Node.new(:table_reference, token, name: token.string)
    end
  end
end
