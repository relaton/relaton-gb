# frozen_string_literal: true

require "relaton/processor"

module Relaton
  module RelatonGb
    class Processor < Relaton::Processor
      def initialize
        @short = :relaton_gb
        @prefix = "CN"
        @defaultprefix = %r{^GB }
        @idtype = "Chinese Standard"
      end

      def get(code, date, opts)
        ::RelatonGb::GbBibliography.get(code, date, opts)
      end

      def from_xml(xml)
        ::RelatonGb::XMLParser.from_xml xml
      end
    end
  end
end
