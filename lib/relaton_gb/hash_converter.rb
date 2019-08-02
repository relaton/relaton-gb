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

        committee_hash_to_bib(ret)
        ccs_hash_to_bib(ret)
        ret
      end

      private

      def committee_hash_to_bib(ret)
        return unless ret[:title]

        ret[:title] = array(ret[:title])
        ret[:title] = ret[:title].map do |t|
          titleparts = {}
          titleparts = split_title(t) unless t.is_a?(Hash)
          if t.is_a?(Hash) && t[:content]
            titleparts = split_title(t[:content], t[:language], t[:script])
          end
          if t.is_a?(Hash) then t.merge(titleparts)
          else
            { content: t, language: "en", script: "Latn", format: "text/plain", type: "main" }
          end
        end
      end

      def ccs_hash_to_bib(ret)
        ret[:ccs] = ret.fetch(:ccs, []).map do |ccs|
          ccs[:code] ? Cnccs.fetch(ccs[:code]) : Cnccs.fetch(ccs)
        end
      end
    end
  end
end
