
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gbbib/version'

Gem::Specification.new do |spec|
  spec.name          = 'gbbib'
  spec.version       = Gbbib::VERSION
  spec.authors       = ['Ribose Inc.']
  spec.email         = ['pen.source@ribose.com']

  spec.summary       = 'GdBib: retrieve Chinese GB Standards for bibliographic'\
                       ' use using the BibliographicItem model.'
  spec.description   = 'GdBib: retrieve Chinese GB Standards for bibliographic'\
                       ' use using the BibliographicItem model.'
  spec.homepage      = 'https://github.com/riboseinc/gdbib'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency "equivalent-xml", "~> 0.6"

  spec.add_dependency 'cnccs'
  spec.add_dependency 'iso-bib-item'
  # spec.add_dependency 'nokogiri'
end