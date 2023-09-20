module RelatonGb
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonGb.configuration.logger
    end
  end
end
