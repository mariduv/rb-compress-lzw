lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lzw'

Gem::Specification.new do |s|
  s.name        = 'compress-lzw'
  s.version     = LZW::VERSION
  s.summary     = "Scaling LZW compression"
  s.description = "Scaling LZW compression, compatible with unix compress(1)"
  s.authors     = [ "Meredith Howard"  ]
  s.email       = [ 'mhoward@cpan.org' ]
  s.license     = 'MIT'
  s.homepage    = 'https://github.com/mariduv/rb-compress-lzw'

  s.files       = `git ls-files -z -- lib/* README.md LICENSE compress-lzw.gemspec`.split("\x0")

  s.required_ruby_version = '~> 3.0'
end

