module Gbbib
  # GB technical committee.
  class GbTechnicalCommittee
    # @return [String]
    attr_reader :type

    # @return [String]
    attr_reader :name

    # @param type [String]
    # @param name [String]
    def initialize(type:, name:)
      @type = type
      @name = name
    end
  end
end
