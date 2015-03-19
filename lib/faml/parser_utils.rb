module Faml
  module ParserUtils
    module_function

    def balance(scanner, start, finish, depth = 1)
      re = /(#{Regexp.escape(start)}|#{Regexp.escape(finish)})/
      while depth > 0 && scanner.scan_until(re)
        if scanner.matched == start
          depth += 1
        else
          depth -= 1
        end
      end
      depth
    end
  end
end
