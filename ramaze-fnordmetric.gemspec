path = File.expand_path('../', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'ramaze-fnordmetric'
  s.version     = '0.0.9'
  s.date        = '2012-06-21'
  s.authors     = ['Michel Blanc']
  s.email       = 'mblanc@erasme.org'
  s.summary     = 'A simple fnordmetric helper for Ramaze.'
  s.homepage    = 'https://github.com/leucos/ramaze-fnordmetric'
  s.description = s.summary
  s.files       = `cd #{path}; git ls-files`.split("\n").sort
  s.has_rdoc    = 'yard'

  s.add_dependency('ramaze', ['>= 2011.07.25'])
  s.add_dependency('redis', ['>= 2.2.0'])
  s.add_dependency('fnordmetric', ['>= 0.9.7'])

  s.add_development_dependency('rake'     , ['>= 0.9.2'])
  s.add_development_dependency('yard'     , ['>= 0.7.2'])
  s.add_development_dependency('bacon'    , ['>= 1.1.0'])
  s.add_development_dependency('rdiscount', ['>= 1.6.8'])
  s.add_development_dependency('rack-test', ['>= 0.6.1'])
  s.add_development_dependency('simplecov')
end
