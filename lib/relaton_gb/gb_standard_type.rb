module RelatonGb
  # GB standard type.
  class GbStandardType
    # @return [String]
    attr_reader :scope

    # @return [String]
    attr_reader :prefix

    # @return [String]
    attr_reader :mandate

    # @param scope [String]
    # @param prefix [String]
    # @param mandate [String]
    def initialize(scope:, prefix:, mandate:)
      @scope   = scope
      @prefix  = prefix
      @mandate = mandate
    end

    def to_xml(builder)
      builder.gbtype do
        builder.gbscope @scope
        builder.gbprefix @prefix
        builder.gbmandate @mandate
      end
    end
  end
end
