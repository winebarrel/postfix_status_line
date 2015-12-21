# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'postfix_status_line/version'

Gem::Specification.new do |spec|
  spec.name          = 'postfix_status_line'
  spec.version       = PostfixStatusLine::VERSION
  spec.authors       = ['Genki Sugawara']
  spec.email         = ['sgwr_dts@yahoo.co.jp']

  spec.summary       = %q{Postfix Status Line Log Parser implemented by C.}
  spec.description   = %q{Postfix Status Line Log Parser implemented by C.}
  spec.homepage      = 'https://github.com/winebarrel/postfix_status_line'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake-compiler'
end
