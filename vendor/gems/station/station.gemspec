$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'station/version'

Gem::Specification.new do |s|

  # define gem
  s.name        = "station"
  s.version     =  Station::VERSION
  s.summary     = "Station is a simplified conversion of station plugin."
  s.description = "Station is a simplified conversion of station plugin. It keeps only those funcionalities needes for this application."
  s.authors     = ['Gnoxys' ]
  s.email       = ['development@gnoxys.net']
  s.homepage    = ''
  s.files       = `git ls-files`.split("\n")

  # dependencies
#  s.add_dependency 'json_pure', '~> 1.5.1'
#  s.add_dependency 'rails',     '>=3.0.3'
#  s.add_dependency 'activerecord', '>=3.0.3'

#  s.add_development_dependency('rspec', '~> 2.5.0')
#  s.add_development_dependency('jasmine', '~> 1.0.2.0')

#  if RUBY_VERSION < '1.9'
#    s.add_development_dependency('ruby-debug', '~> 0.10.3')
#  end
end
