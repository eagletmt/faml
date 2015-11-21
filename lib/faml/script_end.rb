# frozen-string-literal: true
require 'temple'

module Faml
  class ScriptEnd < Temple::Filter
    def on_multi(*exprs)
      i = exprs.size - 1
      depth = 0
      while i >= 0
        case exprs[i]
        when [:mkend]
          if depth > 0
            # Cancel :mkend
            depth -= 1
            exprs.delete_at(i)
          else
            exprs[i] = [:code, 'end'.freeze]
          end
        when [:rmend]
          depth += 1
          exprs.delete_at(i)
        end
        i -= 1
      end
      [:multi, *exprs]
    end
  end
end
