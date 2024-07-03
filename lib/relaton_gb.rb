require "digest/md5"
require "mechanize"
require "relaton_iso_bib"
require "cnccs"
require "relaton_gb/version"
require "relaton_gb/util"
require "relaton_gb/document_type"
require "relaton_gb/gb_bibliography"

# if defined? Relaton
#   require "relaton_gb/processor"
#   # don't register the gem if it's required form relaton's registry
#   return if caller.detect { |c| c.include? "register_gems" }

#   Relaton::Registry.instance.register RelatonGb::Processor
# end

module RelatonGb
  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonGb::VERSION + RelatonIsoBib::VERSION + RelatonBib::VERSION # grammars
  end
end
