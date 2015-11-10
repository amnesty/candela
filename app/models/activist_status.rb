# encoding: utf-8
class ActivistStatus < ActiveRecord::Base

  default_scope where(:enabled => true) if self.column_names.include? 'enabled'

  def self.internship_id
    internship = find(:first, :conditions => "name = 'Prácticas'")
    if internship.nil?
      nil
    else
      internship.id
    end
  end

  def self.active_id
    active = find(:first, :conditions => "name = 'Activo'")
    if active.nil?
      nil
    else
      active.id
    end
  end

  def self.inactive_id
    inactive = find(:first, :conditions => "name = 'Inactivo'")
    if inactive.nil?
      nil
    else
      inactive.id
    end
  end

  def self.leave_proposed_id
    leave_proposed = find(:first, :conditions => "name = 'Propuesto a baja'")
    if leave_proposed.nil?
      nil
    else
      leave_proposed.id
    end
  end

  def self.leave_id
    leave = find(:first, :conditions => "name = 'Baja'")
    if leave.nil?
      nil
    else
      leave.id
    end
  end

end
