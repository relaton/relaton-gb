require "relaton/processor"

module Relaton
  module Gbbib
    class Processor < Relaton::Processor

      def initialize
        @short = :gbbib
        #@prefix = %r{^(GB|GJ|GS)|^ZB|^DB|^Q\/|^T\/[^\s]{3,6}\s}
        @prefix = %r{^GB Standard }
      end

      def get(code, date, opts)
        ::Gbbib::GbBibliography.get(code, date, opts)
      end
    end
  end
end
