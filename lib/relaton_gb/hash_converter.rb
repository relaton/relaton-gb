require "yaml"

module RelatonGb
  class HashConverter < RelatonIsoBib::HashConverter
    class << self
      # @override RelatonBib::HashConverter.hash_to_bib
      # @param args [Hash]
      # @param nested [TrueClass, FalseClass]
      # @return [Hash]
      def hash_to_bib(args, nested = false)
        ret = super
        return if ret.nil?

        ccs_hash_to_bib(ret)
        ret
      end

      private

      def ccs_hash_to_bib(ret)
        ret[:ccs] = array(ret[:ccs]).map do |ccs|
          ccs[:code] ? Cnccs.fetch(ccs[:code]) : Cnccs.fetch(ccs)
        end
      end
    end
  end
end
