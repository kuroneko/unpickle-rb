require 'rake'

Gem::Specification.new do |s|
  s.name        = 'unpickle'
  s.version     = '0.0.1'
  s.date        = '2012-06-01'
  s.summary     = "unpickle python objects in ruby"
  s.description = "A library to unpickle simple python objects directly into ruby"
  s.authors     = ["Chris Collins"]
  s.email       = 'chris@collins.id.au'
  s.files       = Filelist['lib/**/*.rb',
                           '[A-Z]*',
                           'test/**/*']
  s.homepage    = 'http://github.com/kuroneko/unpickle-rb'
  s.test_files  = Filelist['test/**/test_*.rb']
end
