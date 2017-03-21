require 'bigdecimal/math'

module Blackbeard
  module Math
    def self.beta(x,y)
      lx = ::Math.lgamma(x).first
      ly = ::Math.lgamma(y).first
      lxplusy = ::Math.lgamma(x + y).first

      precision = 5
      ::BigMath.exp(lx + ly - lxplusy, precision)
    end
  end
end
