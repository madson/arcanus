module Matchers
  class IncludeJson
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      json = JSON.parse(@actual, symbolize_names: true)
      json.merge(@expected) == json
    end

    def failure_message
      "expected #{@actual} to include #{@expected}"
    end

    def negative_failure_message
      "expected #{@actual} not to include #{@expected}"
    end

    def description
      "include #{@expected}"
    end
  end

  def include_json(expected)
    IncludeJson.new(expected)
  end
end