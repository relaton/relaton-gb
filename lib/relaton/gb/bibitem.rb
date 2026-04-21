module Relaton
  module Gb
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end
