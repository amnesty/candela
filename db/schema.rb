# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130522081903) do

  create_table "POSTAL", :primary_key => "POSTAL_ID", :force => true do |t|
    t.string  "cp"
    t.string  "city"
    t.string  "municipe"
    t.string  "comunity"
    t.integer "PROVINCE_ID",   :limit => 8
    t.string  "province_name"
  end

  add_index "POSTAL", ["PROVINCE_ID"], :name => "FK8D03F0CBE5899933"

  create_table "PROVINCES", :primary_key => "PROVINCE_ID", :force => true do |t|
    t.string  "nameKey"
    t.binary  "visible",  :limit => 1
    t.string  "code",                  :null => false
    t.integer "GROUP_ID", :limit => 8
  end

  create_table "academic_years", :force => true do |t|
    t.string   "year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "academic_years_hr_schools", :id => false, :force => true do |t|
    t.integer "hr_school_id"
    t.integer "academic_year_id"
  end

  create_table "activist_statuses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "activists", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "sex_id"
    t.date     "birth_day"
    t.string   "nif"
    t.string   "address"
    t.integer  "province_id"
    t.string   "cp",                          :limit => 5
    t.integer  "country_id"
    t.string   "phone",                       :limit => 12
    t.string   "mobile_phone",                :limit => 12
    t.string   "email"
    t.integer  "labour_situation_id"
    t.boolean  "student"
    t.boolean  "data_protection_agreement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "student_place"
    t.integer  "student_level_id"
    t.integer  "student_year_id"
    t.string   "last_name2"
    t.integer  "other_languages"
    t.string   "student_degree"
    t.text     "student_previous_degrees"
    t.string   "city"
    t.datetime "join_at"
    t.datetime "leave_at"
    t.integer  "leave_reason_id"
    t.text     "leave_more_info"
    t.string   "document_type",               :limit => 5
    t.text     "other_hobbies"
    t.text     "other_skills"
    t.text     "blogger"
    t.text     "student_more_info"
    t.integer  "informed_through_id"
    t.text     "informed_through_other"
    t.integer  "occupation_id"
    t.text     "other_information"
    t.boolean  "different_residence_country"
    t.string   "partnership_id"
  end

  create_table "activists_collaborations", :force => true do |t|
    t.integer  "activist_id"
    t.integer  "organization_id"
    t.string   "organization_type"
    t.string   "collaboration_type"
    t.datetime "join_at"
    t.datetime "leave_at"
    t.integer  "leave_reason_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activist_status_id"
    t.datetime "activist_status_changed_at"
    t.text     "more_info"
    t.integer  "availability_id"
    t.string   "autonomy_type"
  end

  create_table "activists_collaborations_autonomic_teams", :id => false, :force => true do |t|
    t.string  "activists_collaboration_id"
    t.integer "autonomic_team_id"
  end

  create_table "activists_collaborations_committees", :id => false, :force => true do |t|
    t.integer "activists_collaboration_id"
    t.integer "committee_id"
  end

  create_table "activists_collaborations_expertises", :id => false, :force => true do |t|
    t.integer "activists_collaboration_id"
    t.integer "expertise_id"
  end

  create_table "activists_collaborations_responsibilities", :id => false, :force => true do |t|
    t.integer "activists_collaboration_id"
    t.integer "responsibility_id"
  end

  create_table "activists_collabtopics", :id => false, :force => true do |t|
    t.integer "activist_id"
    t.integer "collabtopic_id"
  end

  create_table "activists_hobbies", :id => false, :force => true do |t|
    t.integer "activist_id"
    t.integer "hobby_id"
  end

  create_table "activists_languages", :id => false, :force => true do |t|
    t.integer "activist_id"
    t.integer "language_id"
  end

  create_table "activists_skills", :id => false, :force => true do |t|
    t.integer "activist_id"
    t.integer "skill_id"
  end

  create_table "activists_statuschanges", :force => true do |t|
    t.datetime "date"
    t.integer  "activist_status_id"
    t.integer  "leave_reason_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "activist_id"
    t.integer  "activists_collaboration_id"
  end

  create_table "activists_talks", :force => true do |t|
    t.integer  "talk_id"
    t.integer  "activist_id"
    t.boolean  "attended"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "alert_definitions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.boolean  "enabled",             :default => true
    t.string   "watched_table"
    t.string   "watched_field"
    t.string   "watched_joins"
    t.string   "watched_where"
    t.date     "start_date",          :default => '2009-01-01'
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "days_for_triggering", :default => 0
  end

  create_table "alert_definitions_roles", :id => false, :force => true do |t|
    t.integer "alert_definition_id"
    t.integer "role_id"
  end

  create_table "alerts", :force => true do |t|
    t.integer  "alert_definition_id"
    t.integer  "record_id"
    t.boolean  "closed"
    t.date     "closed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.string   "type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",          :default => 0
    t.datetime "created_at"
    t.string   "comment"
    t.string   "remote_address"
    t.integer  "association_id"
    t.string   "association_type"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "autonomic_teams", :force => true do |t|
    t.string   "name"
    t.integer  "autonomy_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "autonomic_teams", ["autonomy_id"], :name => "index_autonomic_teams_on_autonomy_id"

  create_table "autonomies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
    t.string   "address"
    t.string   "cp",                     :limit => 5
    t.string   "city"
    t.integer  "province_id"
    t.string   "phone",                  :limit => 12
    t.string   "fax",                    :limit => 9
    t.string   "email"
    t.string   "email_2"
    t.string   "postal_address"
    t.string   "postal_cp"
    t.string   "postal_city"
    t.integer  "postal_province_id"
    t.string   "delivery_address"
    t.string   "delivery_cp"
    t.string   "delivery_city"
    t.integer  "delivery_province_id"
    t.string   "delivery_contact"
    t.string   "delivery_phone",         :limit => 12
    t.string   "delivery_hours"
    t.integer  "meeting_weekday"
    t.string   "meeting_frequency"
    t.string   "meeting_hours"
    t.string   "meeting_venue"
    t.text     "customer_service_time"
    t.boolean  "collaborations_enabled",               :default => true
    t.boolean  "show_to_interesteds"
  end

  create_table "availabilities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "available_hours", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "board_positions", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaignactions", :force => true do |t|
    t.integer "campaign_id"
    t.integer "campaigntopic_id"
    t.string  "contact_person"
    t.string  "contact_phone",                      :limit => 12
    t.string  "contact_email"
    t.boolean "mobilization"
    t.text    "mobilization_description"
    t.boolean "institutional"
    t.text    "institutional_authorities_contact"
    t.text    "institutional_other"
    t.boolean "media"
    t.text    "media_material_distrib"
    t.text    "media_other"
    t.boolean "sectorial"
    t.text    "sectorial_NGO"
    t.text    "sectorial_other"
    t.boolean "activists_raising"
    t.text    "activists_raising_material_distrib"
    t.text    "activists_raising_interesteds"
    t.integer "organization_id"
    t.string  "organization_type"
    t.text    "mobilization_to_who"
    t.text    "used_material"
    t.text    "interesteds_comments"
    t.text    "interesteds_signs"
    t.text    "media_urls"
    t.text    "activists_raising_member_commited"
    t.boolean "web_2_0"
    t.text    "web_2_0_specific_actions"
    t.boolean "school_network"
    t.text    "school_network_description"
    t.boolean "society_movement"
    t.text    "society_movement_description"
    t.boolean "join_organizations"
    t.text    "join_organizations_description"
    t.boolean "other_info"
    t.text    "other_info_description"
    t.text    "positive_facts"
    t.text    "improve_facts"
    t.boolean "gender_approach"
    t.text    "gender_approach_description"
    t.text    "gender_approach_tool_evaluation"
  end

  create_table "campaigns", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaigntopic_id"
    t.integer  "country_id"
    t.date     "starting_at"
    t.date     "ending_at"
  end

  create_table "campaigntopics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "domain_id"
    t.string   "domain_type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categorizations", :force => true do |t|
    t.integer "category_id"
    t.integer "categorizable_id"
    t.string  "categorizable_type"
  end

  create_table "cities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "province_id"
    t.string   "cp",          :limit => 5
  end

  create_table "collabtopics", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "collabtopics_interesteds", :id => false, :force => true do |t|
    t.integer "interested_id"
    t.integer "collabtopic_id"
  end

  create_table "committees", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
    t.string   "address"
    t.string   "cp",                     :limit => 5
    t.string   "city"
    t.integer  "province_id"
    t.string   "phone",                  :limit => 12
    t.string   "fax",                    :limit => 9
    t.string   "email"
    t.string   "email_2"
    t.string   "postal_address"
    t.string   "postal_cp"
    t.string   "postal_city"
    t.integer  "postal_province_id"
    t.string   "delivery_address"
    t.string   "delivery_cp"
    t.string   "delivery_city"
    t.integer  "delivery_province_id"
    t.string   "delivery_contact"
    t.string   "delivery_phone",         :limit => 12
    t.string   "delivery_hours"
    t.integer  "meeting_weekday"
    t.string   "meeting_frequency"
    t.string   "meeting_hours"
    t.string   "meeting_venue"
    t.text     "customer_service_time"
    t.boolean  "collaborations_enabled",               :default => true
  end

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "isoname",                :limit => 2
    t.boolean  "has_linked_campaigns"
    t.boolean  "enabled"
    t.boolean  "collaborations_enabled",               :default => false
    t.string   "address"
    t.string   "cp",                     :limit => 5
    t.string   "city"
    t.integer  "province_id"
    t.string   "phone",                  :limit => 12
    t.string   "fax",                    :limit => 9
    t.string   "email"
    t.string   "email_2"
    t.string   "postal_address"
    t.string   "postal_cp"
    t.string   "postal_city"
    t.integer  "postal_province_id"
    t.string   "delivery_address"
    t.string   "delivery_cp"
    t.string   "delivery_city"
    t.integer  "delivery_province_id"
    t.string   "delivery_contact"
    t.string   "delivery_phone",         :limit => 12
    t.string   "delivery_hours"
    t.integer  "meeting_weekday"
    t.string   "meeting_frequency"
    t.string   "meeting_hours"
    t.string   "meeting_venue"
    t.text     "customer_service_time"
    t.boolean  "show_in_collaborations",               :default => false
  end

  create_table "db_files", :force => true do |t|
    t.binary "data"
  end

  create_table "event_definitions", :force => true do |t|
    t.string   "codename"
    t.string   "klass"
    t.string   "name"
    t.string   "description"
    t.string   "watched_model"
    t.string   "watched_actions"
    t.string   "timestamp_field"
    t.boolean  "is_unique",          :default => false
    t.string   "info_fields"
    t.text     "trigger_conditions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_records", :force => true do |t|
    t.integer  "event_definition_id"
    t.text     "type"
    t.integer  "audit_id"
    t.integer  "item_id"
    t.datetime "timestamp"
    t.text     "info"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expertises", :force => true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hobbies", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hobbies_interesteds", :id => false, :force => true do |t|
    t.integer "interested_id"
    t.integer "hobby_id"
  end

  create_table "hr_school_levels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hr_school_levels_hr_schools", :id => false, :force => true do |t|
    t.integer "hr_school_id"
    t.integer "hr_school_level_id"
  end

  create_table "hr_school_organization_managers", :force => true do |t|
    t.integer "hr_school_id"
    t.string  "organization_type"
    t.integer "organization_id"
  end

  create_table "hr_schools", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.date     "join_at"
    t.date     "leave_at"
    t.string   "address"
    t.integer  "province_id"
    t.string   "cp",                         :limit => 5
    t.string   "city"
    t.string   "email"
    t.string   "phone",                      :limit => 12
    t.string   "contact_name"
    t.string   "contact_position"
    t.boolean  "direction_approval"
    t.string   "tutor"
    t.string   "tutor_phone",                :limit => 12
    t.integer  "pupils_count"
    t.text     "years"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fax",                        :limit => 9
    t.string   "web_page"
    t.string   "phone2",                     :limit => 12
    t.string   "hr_type"
    t.text     "type_other"
    t.string   "hr_school_level_other"
    t.boolean  "school_management"
    t.integer  "assigned_organization_id"
    t.string   "assigned_organization_type"
    t.text     "ages"
    t.string   "contact_email"
    t.string   "contact_phone"
    t.string   "contact_tweeter"
    t.boolean  "is_partner"
    t.boolean  "is_activist"
  end

  create_table "hr_schools_hr_work_throughs", :id => false, :force => true do |t|
    t.integer "hr_school_id"
    t.integer "hr_work_through_id"
  end

  create_table "hr_work_throughs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "informed_throughs", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "interesteds", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "last_name2"
    t.integer  "sex_id"
    t.date     "birth_day"
    t.string   "document_type",               :limit => 5
    t.string   "nif"
    t.string   "address"
    t.integer  "country_id"
    t.integer  "province_id"
    t.string   "cp",                          :limit => 5
    t.string   "city"
    t.string   "phone",                       :limit => 12
    t.string   "mobile_phone",                :limit => 12
    t.string   "email"
    t.integer  "labour_situation_id"
    t.boolean  "student"
    t.text     "student_previous_degrees"
    t.string   "student_place"
    t.integer  "student_level_id"
    t.integer  "student_year_id"
    t.string   "student_degree"
    t.integer  "other_languages"
    t.text     "other_skills"
    t.text     "other_hobbies"
    t.text     "wants_todo"
    t.text     "blogger"
    t.integer  "local_organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "student_more_info"
    t.integer  "occupation_id"
    t.integer  "activist_id"
    t.boolean  "minor_checked"
    t.boolean  "different_residence_country"
    t.boolean  "email_sent"
    t.boolean  "letter_sent"
    t.integer  "informed_through_id"
    t.text     "informed_through_other"
    t.string   "email_2"
  end

  create_table "interesteds_languages", :id => false, :force => true do |t|
    t.integer "interested_id"
    t.integer "language_id"
  end

  create_table "interesteds_skills", :id => false, :force => true do |t|
    t.integer "interested_id"
    t.integer "skill_id"
  end

  create_table "interesteds_talks", :force => true do |t|
    t.integer "interested_id"
    t.integer "talk_id"
    t.boolean "attended"
  end

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.string   "email"
    t.integer  "agent_id"
    t.string   "agent_type"
    t.integer  "stage_id"
    t.string   "stage_type"
    t.integer  "role_id"
    t.string   "acceptation_code"
    t.datetime "accepted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labour_situations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leave_reasons", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "local_organizations", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.integer  "province_id"
    t.string   "phone",                  :limit => 12
    t.string   "email"
    t.string   "fax",                    :limit => 9
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email_2"
    t.string   "city"
    t.string   "cp",                     :limit => 5
    t.string   "number"
    t.string   "postal_address"
    t.string   "postal_cp"
    t.string   "postal_city"
    t.integer  "postal_province_id"
    t.string   "delivery_address"
    t.string   "delivery_cp"
    t.string   "delivery_city"
    t.integer  "delivery_province_id"
    t.string   "delivery_contact"
    t.string   "delivery_phone",         :limit => 12
    t.string   "delivery_hours"
    t.integer  "meeting_weekday"
    t.string   "meeting_frequency"
    t.string   "meeting_hours"
    t.boolean  "enabled"
    t.string   "meeting_venue"
    t.text     "customer_service_time"
    t.boolean  "collaborations_enabled",               :default => true
    t.boolean  "show_to_interesteds"
  end

  create_table "logos", :force => true do |t|
    t.integer  "logoable_id"
    t.string   "logoable_type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "db_file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mail_template_assignments", :force => true do |t|
    t.string   "consumer_type"
    t.integer  "consumer_id"
    t.integer  "mail_template_collection_id"
    t.string   "template_name"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "mail_template_collections", :force => true do |t|
    t.string   "codename"
    t.text     "description"
    t.text     "default_template_name"
    t.text     "available_consumers_script"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "notes", :force => true do |t|
    t.integer  "noteable_id"
    t.string   "noteable_type"
    t.string   "title"
    t.text     "body"
    t.integer  "created_by"
    t.string   "parents"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "monitoring_person"
    t.date     "monitoring_date"
    t.string   "monitoring_topic"
  end

  create_table "occupations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organization_on_offs", :force => true do |t|
    t.integer "organization_id"
    t.string  "organization_type"
    t.text    "more_info"
    t.date    "date"
    t.string  "on_or_off",         :limit => 3
  end

  create_table "organizations_trackings", :force => true do |t|
    t.integer "user_id"
    t.string  "organization_type"
    t.integer "organization_id"
  end

  create_table "performances", :force => true do |t|
    t.integer "agent_id"
    t.string  "agent_type"
    t.integer "role_id"
    t.integer "stage_id"
    t.string  "stage_type"
  end

  create_table "permissions", :force => true do |t|
    t.string "action"
    t.string "objective"
  end

  create_table "permissions_roles", :id => false, :force => true do |t|
    t.integer "permission_id"
    t.integer "role_id"
  end

  create_table "provinces", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
  end

  create_table "responsibilities", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "for_member"
    t.boolean  "for_autonomy"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
    t.string "stage_type"
    t.text   "description"
  end

  create_table "se_teams", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "enabled"
    t.string   "address"
    t.string   "cp",                     :limit => 5
    t.string   "city"
    t.integer  "province_id"
    t.string   "phone",                  :limit => 12
    t.string   "fax",                    :limit => 9
    t.string   "email"
    t.string   "email_2"
    t.string   "postal_address"
    t.string   "postal_cp"
    t.string   "postal_city"
    t.integer  "postal_province_id"
    t.string   "delivery_address"
    t.string   "delivery_cp"
    t.string   "delivery_city"
    t.integer  "delivery_province_id"
    t.string   "delivery_contact"
    t.string   "delivery_phone",         :limit => 12
    t.string   "delivery_hours"
    t.integer  "meeting_weekday"
    t.string   "meeting_frequency"
    t.string   "meeting_hours"
    t.string   "meeting_venue"
    t.text     "customer_service_time"
    t.boolean  "collaborations_enabled",               :default => true
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "sexes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "singular_agents", :force => true do |t|
    t.string "type"
  end

  create_table "sites", :force => true do |t|
    t.string   "name",                          :default => "Station powered Rails site"
    t.text     "description"
    t.string   "domain",                        :default => "station.example.org"
    t.string   "email",                         :default => "admin@example.org"
    t.boolean  "ssl",                           :default => false
    t.boolean  "exception_notifications",       :default => false
    t.string   "exception_notifications_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "create_permissions_as_roles",   :default => false
  end

  create_table "skills", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_levels", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "student_years", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talks", :force => true do |t|
    t.string   "name"
    t.datetime "date"
    t.string   "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "hours"
    t.integer  "seats",             :limit => 8
    t.integer  "organization_id"
    t.string   "organization_type"
  end

  create_table "uris", :force => true do |t|
    t.string "uri"
  end

  add_index "uris", ["uri"], :name => "index_uris_on_uri"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "reset_password_code",       :limit => 40
  end

end
