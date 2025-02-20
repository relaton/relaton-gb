module Relaton
  module Gb
    class Doctype < Bib::Doctype
      TYPES = %w[standard recommendation].freeze

      attribute :type, :string, values: TYPES
    end
  end
end
