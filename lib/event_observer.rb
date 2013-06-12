class EventObserver < ActiveRecord::Observer #:nodoc:

  observe [:activist, :activists_collaboration, :interested, :talk, :hr_school, :note]

  def after_create(item)
    EventDefinition.check_item item, :create
  end

  def after_update(item)
    EventDefinition.check_item item, :update
  end

  def after_destroy(item)
    EventRecord.for_object(item).destroy_all
#    EventDefinition.check_item item, :destroy
  end

end

