module Cnccs
  class Ccs
    # @return [Hash]
    def to_hash
      { "code" => code }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [String]
    def to_aciibib(prefix = "", count = 1)
      pref = prefix.empty? ? prefix : prefix + "."
      pref += "ccs"
      out = count > 1 ? "#{pref}::\n" : ""
      out += "#{pref}.code:: #{code}\n" if code
      out += "#{pref}.description:: #{description}\n" if description
      out
    end
  end
end
