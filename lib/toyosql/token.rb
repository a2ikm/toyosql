class Toyosql
  class Token
    attr_reader :type, :string

    def initialize(type, string)
      @type = type
      @string = string
    end
  end
end
