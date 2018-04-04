
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gdbib/version"

Gem::Specification.new do |spec|
  spec.name          = "gdbib"
  spec.version       = Gdbib::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["pen.source@ribose.com"]

  spec.summary       = %q{GdBib: retrieve Chinese GB Standards for bibliographic use using the BibliographicItem model.}
  spec.description   = %q{GdBib: retrieve Chinese GB Standards for bibliographic use using the BibliographicItem model.}
  spec.homepage      = "https://github.com/riboseinc/gdbib"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry-byebug"

  spec.add_dependency "isoics"
  spec.add_dependency "algoliasearch"
  spec.add_dependency "nokogiri"
end
