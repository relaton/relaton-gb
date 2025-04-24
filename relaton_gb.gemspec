
lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "relaton_gb/version"

Gem::Specification.new do |spec|
  spec.name          = "relaton-gb"
  spec.version       = RelatonGb::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["pen.source@ribose.com"]

  spec.summary       = "RelatonGb: retrieve Chinese GB Standards for bibliographic"\
                       " use using the BibliographicItem model."
  spec.description   = "RelatonGb: retrieve Chinese GB Standards for bibliographic"\
                       " use using the BibliographicItem model."
  spec.homepage      = "https://github.com/metanorma/relaton_gb"
  spec.license       = "BSD-2-Clause"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.add_dependency "cnccs", "~> 0.1.1"
  spec.add_dependency "connection_pool", "~> 2.4.0" # @TODO v2.5 has an issue with Windows
  spec.add_dependency "gb-agencies", "~> 0.0.1"
  spec.add_dependency "mechanize", "~> 2.10"
  spec.add_dependency "relaton-iso-bib", "~> 1.20.0"
  spec.add_dependency "csv", "~> 3.0"
end
