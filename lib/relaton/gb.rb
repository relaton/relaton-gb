require "digest/md5"
require "mechanize"
require "relaton/core"
require "relaton/iso"
require "cnccs"
require_relative "gb/version"
require_relative "gb/util"
require_relative "gb/item_data"
require_relative "gb/item"
require_relative "gb/bibitem"
require_relative "gb/bibdata"
require_relative "gb/bibliography"

# if defined? Relaton
#   require "relaton_gb/processor"
#   # don't register the gem if it's required form relaton's registry
#   return if caller.detect { |c| c.include? "register_gems" }

#   Relaton::Registry.instance.register RelatonGb::Processor
# end

module Relaton
  module Gb
    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Gb::VERSION + Relaton::Iso::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end
