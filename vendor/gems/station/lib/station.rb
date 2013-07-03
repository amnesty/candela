
# Core Extensions
require_dependency 'station/core_ext'

module ActiveRecord
  autoload :ActsAs,             'active_record/acts_as'
  autoload :Authorization,      'active_record/authorization'
end  

module ActionController
  autoload :Station,        'action_controller/station'
  autoload :Authorization,  'action_controller/authorization'
end

# Inflections
ActiveSupport::Inflector.inflections do |inflect|
  inflect.uncountable 'cas'
  inflect.uncountable 'anonymous'
end

# Require our engine
require "station/engine"

