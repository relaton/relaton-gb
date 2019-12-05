module RelatonGb
  # GB standard type.
  class GbStandardType
    # @return [String]
    attr_reader :scope, :prefix, :mandate, :topic

    # @param scope [String]
    # @param prefix [String]
    # @param mandate [String]
    # @param topic [String]
    def initialize(scope:, prefix:, mandate:, topic:)
      @scope   = scope
      @prefix  = prefix
      @mandate = mandate
      @topic   = topic
    end

    def to_xml(builder)
      builder.gbtype do
        builder.gbscope scope
        builder.gbprefix prefix
        builder.gbmandate mandate
        builder.gbtopic topic
      end
    end

    # @return [Hash]
    def to_hash
      { "scope" => scope, "prefix" => prefix, "mandate" => mandate, "topic" => topic }
    end
  end
end
