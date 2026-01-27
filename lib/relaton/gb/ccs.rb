module Relaton
  module Gb
    class CCS < Bib::ICS
      attribute :text, method: :get_text

      xml do
        root "ccs"
        map_element "code", to: :code
        map_element "text", to: :text
      end

      def get_text
        Cnccs.fetch(code).description if code
      end
    end
  end
end
