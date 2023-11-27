module RelatonGb
  module HashConverter
    include RelatonIsoBib::HashConverter
    extend self

    # @override RelatonBib::HashConverter.hash_to_bib
    # @param args [Hash]
    # @param nested [TrueClass, FalseClass]
    # @return [Hash]
    def hash_to_bib(args)
      ret = super
      return if ret.nil?

      ccs_hash_to_bib(ret)
      ret
    end

    private

    #
    # Ovverides superclass's method
    #
    # @param item [Hash]
    # @retirn [RelatonGb::GbBibliographicItem]
    def bib_item(item)
      GbBibliographicItem.new(item)
    end

    def ccs_hash_to_bib(ret)
      ret[:ccs] = RelatonBib.array(ret[:ccs]).map do |ccs|
        (ccs[:code] && Cnccs.fetch(ccs[:code])) || Cnccs.fetch(ccs)
      end
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
