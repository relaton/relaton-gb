require_relative "ext"

module Relaton
  module Gb
    class Item < Iso::Item
      model Bib::ItemData

      attribute :ext, Ext
    end
  end
end
