require 'rake'

Gem::Specification.new do |s|
  s.name        = 'unpickle'
  s.version     = '0.0.2'
  s.date        = '2012-06-01'
  s.summary     = "unpickle python objects in ruby"
  s.description = "A library to unpickle simple python objects directly into ruby"
  s.authors     = ["Chris Collins"]
  s.email       = 'kuroneko-rubygems@sysadninjas.net'
  s.files       = FileList['lib/**/*.rb',
                           '[A-Z]*',
                           'test/**/*']
  s.homepage    = 'http://github.com/kuroneko/unpickle-rb'
  s.test_files  = FileList['test/**/test_*.rb']
end
