require "relaton_gb/version"
require "relaton_gb/gb_bibliography"

if defined? Relaton
  require_relative "relaton/processor"
  Relaton::Registry.instance.register Relaton::RelatoGb::Processor
end
