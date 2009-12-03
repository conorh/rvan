Gem::Specification.new do |s|
  s.name = 'rvan'
  s.version = '0.1'
  s.date = '2009-12-03'
  s.authors = ['Conor Hunt']
  s.email = 'conor@eastmedia.com'
  s.summary = %q{Ruby wrapper for the Voter Activation Network (VAN) SOAP APIs.}
  s.homepage = 'http://github.com/conorh/rvan/'
  s.description = %q{Ruby wrapper for the Voter Activation Network (VAN) SOAP APIs.}

  s.files = ['README', 'LICENSE', 'Changelog'] + Dir['lib/**/*'].to_a

  s.add_dependency('patron', '>= 0.4.3')
  s.add_dependency('xml-simple', '>= 1.0.12')
end