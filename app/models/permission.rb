#FIXME: INDEPENDIZE dependency from its path!
require_dependency "#{Rails.root}/vendor/gems/station/app/models/permission"
class Permission

  validates_uniqueness_of :action, :scope => [:objective]

  def title
    objective ?
      I18n.t("form.permissions.#{action}") + " " + Gx.t_model(objective.underscore) :
      I18n.t("form.permissions.#{action}")
  end

end
