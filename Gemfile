Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in gdbib.gemspec
gemspec

gem "lutaml-model", github: "lutaml/lutaml-model", branch: "main"
gem "relaton-bib", github: "relaton/relaton-bib", branch: "upd-lutaml-model-to-0-8-0"
gem "relaton-iso", github: "relaton/relaton-iso", branch: "upd-lutaml-model-to-0.8.0"

gem "equivalent-xml", "~> 0.6"
gem "pry-byebug"
gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "ruby-jing"
gem "simplecov"
gem "vcr"
gem "webmock"
