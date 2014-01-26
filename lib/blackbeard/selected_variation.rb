module Blackbeard
  class SelectedVariation
    def initialize(test, variation)
      @test = test
      @variation = variation
    end

    def ==(s)
      @test.add_variation(s)
      @variation == s.to_s
    end
  end
end
