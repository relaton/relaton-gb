require 'gbbib/version'
require 'gbbib/gb_bibliography'

if defined? Relaton
  require_relative 'relaton/processor'
  Relaton::Registry.instance.register Relaton::Gbbib::Processor
end