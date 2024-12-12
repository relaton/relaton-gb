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

      ret[:committee] = ret[:ext][:committee] if ret.dig(:ext, :committee)
      ret[:plannumber] = ret[:ext][:plannumber] if ret.dig(:ext, :plannumber)
      ret[:gbtype] = ret[:ext][:gbtype] if ret.dig(:ext, :gbtype)
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
      ccs = ret.dig(:ext, :ccs) || ret[:ccs] # @TODO: remove ret[:ccs] after all specs are updated
      return unless ccs

      ret[:ccs] = RelatonBib.array(ccs).map do |item|
        (item[:code] && Cnccs.fetch(item[:code])) || Cnccs.fetch(item)
      end
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end
