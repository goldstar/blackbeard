require 'bigdecimal/math'

module Blackbeard
  module Math
    def self.beta(x,y)
      lx = ::Math.lgamma(x).first
      ly = ::Math.lgamma(y).first
      lxplusy = ::Math.lgamma(x + y).first

      ::Math.exp(lx + ly - lxplusy)
    end
  end
end
