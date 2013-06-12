
module Station
  class Engine < Rails::Engine

#  ['active_record','action_controller','action_view'].each do |comp_name|
#    Dir["#{Station::Engine.root}/lib/#{comp_name}/**/"].each{|p|config.autoload_paths << p}
#  end
#puts "+-+-+-+-+-+ Station::Engine.autoload_paths: #{config.autoload_paths.inspect}"

#    # Add a to_prepare block which is executed once in production
#    # and before each request in development
#    config.to_prepare do
#      Station::Engine.setup!
#    end

    initializer 'station.initialize' do
#    config.to_prepare do
#      # ActiveRecord
      ActiveRecord::Base.send :include, ActiveRecord::Authorization
      ActiveRecord::Base.extend ActiveRecord::ActsAs

# Singular Agents
require_dependency "#{Station::Engine.root}/app/models/singular_agent"
if SingularAgent.table_exists?
  SingularAgent
  Anonymous.current
  Anyone.current
  Authenticated.current
end

      # ActionController
      for mod in [ ActionController::Station, ActionController::Authentication, ActionController::Authorization ]
        ActionController::Base.send(:include, mod) unless ActionController::Base.ancestors.include?(mod)
      end

      # ActionView
      # Helpers
      %w( categories logos sortable sources station tags ).each do |item|
        require_dependency "action_view/helpers/#{ item }_helper"
        ActionView::Base.send :include, "ActionView::Helpers::#{ item.camelcase }Helper".constantize
      end

      # FormHelpers
      %w( categories logo tags ).each do |item|
        require_dependency "action_view/helpers/form_#{ item }_helper"
        ActionView::Base.send :include, "ActionView::Helpers::Form#{ item.camelcase }Helper".constantize
      end

    end

  end
end
