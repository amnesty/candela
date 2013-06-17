  # Activate observer for event registering that should always be running 
  ActiveRecord::Base.observers << :event_observer if EventDefinition.table_exists?

  # Uncomment to disable audit creation for all models
#  AiVoluntariado::Application.config.after_initialize { begin ; Audit.audited_classes.each {|klass| klass.disable_auditing} ; rescue ; puts "Couldn't disable audits #{$!} ... but continuing process anyway" ; end  }

