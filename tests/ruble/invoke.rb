module Ruble
  class Invoke
    
    def initialize
      @hash = {}
    end
  
    def method_missing(symbol, *args)
      if symbol.to_s.end_with? "="
        @hash[symbol.to_s[0..-2]] = args.first
      else
        @hash[symbol.to_s]
      end
    end
    
    def is_block?
      active.kind_of? Proc
    end
    
    def active
      all # FIXME Check platform specific first: mac windows linux unix
    end
  end
end
