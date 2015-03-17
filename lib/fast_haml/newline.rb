require 'temple'

module FastHaml
  class Newline < Temple::Filter
    def on_multi(*exprs)
      i = exprs.size-1
      marker = false
      while i >= 0
        case exprs[i]
        when [:rmnl]
          if marker
            raise "InternalError: double rmnl error"
          else
            marker = true
            exprs.delete_at(i)
          end
        when [:mknl]
          if marker
            marker = false
            exprs.delete_at(i)
          else
            exprs[i] = [:static, "\n"]
          end
        end
        i -= 1
      end
      [:multi, *exprs]
    end
  end
end
