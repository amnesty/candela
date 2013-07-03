
module Station
  class Engine < Rails::Engine

    initializer 'station.initialize' do

      # ActiveRecord
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
      for mod in [ ActionController::Station, ActionController::Authorization ]
        ActionController::Base.send(:include, mod) unless ActionController::Base.ancestors.include?(mod)
      end

    end

  end
end
