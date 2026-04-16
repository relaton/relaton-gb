module Relaton
  module Gb
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end
