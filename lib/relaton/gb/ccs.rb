module Relaton
  module Gb
    class CCS < Bib::ICS
      xml { root "ccs" }

      def text
        val = @text
        return val if val && !val.empty?

        Cnccs.fetch(code)&.description if code
      end
    end
  end
end
