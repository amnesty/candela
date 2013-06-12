# Patch for ransack (https://github.com/ernie/ransack) to use scopes
# Helps migrating from Searchlogic or MetaSearch
# Place this file into config/initializer/ransack.rb of your Rails 3.2 project
#
# Usage:
# class Debt < ActiveRecord::Base
# scope :overdue, lambda { where(["status = 'open' AND due_date < ?", Date.today]) }
# end
#
# Ransack out of the box ignores scopes. Example:
# Debt.ransack(:overdue => true, :amount_gteq => 10).result.to_sql
# => "SELECT `debts`.* FROM `debts` AND (`debts`.`amount` >= 10.0)"
#
# This is changed by the patch. Example:
# Debt.ransack_with_scopes(:overdue => true).result.to_sql
# => "SELECT `debts`.* FROM `debts` WHERE `debts`.`status` = 'open' AND (due_date < '2012-11-23') AND (`debts`.`amount` >= 10.0)"
#
# BEWARE: Every scope (and class method) of the model is available. This may be a security issue!
#
module Ransack
  module Adapters
    module ActiveRecord
      module Base
        def ransack_with_scopes(params = {}, options = {})
          ransack_scope = self
          ransack_params = {}
           
          # Extract params which refer to a scope
          (params||{}).each_pair do |k,v|
            if ransack_scope.respond_to?(k)
              ransack_scope = if (v == true)
                ransack_scope.send(k)
              else
                ransack_scope.send(k, v)
              end
            else
              ransack_params.merge!(k => v)
            end
          end
           
          ransack_scope.ransack(ransack_params, options)
        end
      end
    end
  end
end
