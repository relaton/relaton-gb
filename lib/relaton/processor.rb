# frozen_string_literal: true

require "relaton/processor"

module Relaton
  module Gbbib
    class Processor < Relaton::Processor

      def initialize
        @short = :gbbib
        @prefix = "CN"
        @defaultprefix = %r{^GB }
        @idtype = "Chinese Standard"
      end

      def get(code, date, opts)
        ::Gbbib::GbBibliography.get(code, date, opts)
      end

      def from_xml(xml)
        ::Gbbib::XMLParser.from_xml xml
      end
    end
  end
end
