module Matchers
  class IncludeError
    def initialize(expected)
      @expected = expected
    end

    def on(attribute)
      @attribute = attribute
      self
    end

    def matches?(actual)
      actual.errors[@attribute].include?(@expected)
    end

    def failure_message
      "expected errors to include '#{@expected}'"
    end

    def negative_failure_message
      "expected errors not to include '#{@expected}'"
    end
  end

  def include_error(expected)
    IncludeError.new(expected)
  end
end