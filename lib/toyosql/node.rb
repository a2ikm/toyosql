class Toyosql
  class Node
    attr_reader :type, :token, :from, :name, :select_exprs, :table, :value

    def initialize(type, token, from: nil, name: nil, select_exprs: nil, table: nil, value: nil)
      @type = type
      @token = token
      @from = from
      @name = name
      @select_exprs = select_exprs
      @table = table
      @value = value
    end
  end
end
