class Toyosql
  class Lexer
    RESERVED = %w(
      ,
      .
      from
      select
      insert
    ).freeze

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

        if RESERVED.include?(current)
          tokens << Token.new(:reserved, current)
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
end
