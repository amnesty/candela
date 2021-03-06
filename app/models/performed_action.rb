class PerformedAction < ActiveRecord::Base

  attr_accessible :type, :custom_name, :custom_action_topic_ids, :custom_action_topic_other,
                  :organization_type, :organization_id, :campaign_id, :contact_person, :contact_phone, :contact_email, 
                  :mobilization, :mobilization_description, :mobilization_pre, :mobilization_pre_description, :mobilization_to_who,  
                  :mobilization_tour, :mobilization_tour_description, 
                  :used_material, :used_material_evaluation, :used_material_others, :used_material_others_description,
                  :interesteds_comments, :interesteds_signs, :media_urls, 
                  :activists_raising, :activists_raising_member_commited, :activists_raising_expert, :activists_raising_material_distrib, :activists_raising_interesteds, 
                  :gender_approach, :gender_approach_applied, :gender_approach_description, :gender_approach_tool_evaluation, 
                  :media, :media_material_distrib, :web_2_0, :web_2_0_specific_actions, 
                  :institutional, :institutional_authorities_contact, :institutional_other, 
                  :school_network, :school_network_description, :society_movement, :society_movement_description, 
                  :join_organizations, :join_organizations_description, :other_info, :other_info_description,
                  :positive_facts, :improve_facts

  include ActiveRecord::AIActiveRecord

  def self.action_types
    ["Campaignaction","CustomAction"]
  end

  belongs_to :campaign
  has_and_belongs_to_many :custom_action_topics

  belongs_to :organization, :polymorphic => true

  validates_format_of :contact_email, :with => REGEXP_EMAIL, :on => :save, :allow_blank => true
  
  validates_numericality_of :contact_phone, :allow_blank => true
  validates_length_of       :contact_phone, :allow_blank => true, :is => 9
  
  validates_presence_of :type, :organization_id, :organization_type

  scope :can_see, lambda { |agent|
    if agent.is_a?(User)
      if agent.has_any_permission_to(:read, :activist, :on => Site.current)
        {}
      else
      ps = 
        agent.performances.all(:include    => [ :role => :permissions ],
                               :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'PerformedAction', 'Site' ]
                               )
        conditions = ps.collect{|p| "(performed_actions.organization_id = '#{ p.stage_id }' AND performed_actions.organization_type = '#{ p.stage_type }')" }
        conditions = conditions.empty? ? "1 = 0" : conditions.compact.join('OR')
        {:conditions => conditions}
      end
    else
      where("1 = 0")
    end
  
  }
  
  def self.default_order_field
    "performed_actions.id"
  end
  
  def self.default_order_direction
    "DESC"
  end

  def to_title
    "#{ organization.to_title }/#{ custom_name || campaign.name }"
  end
  
  def self.has_fast_search?
    false
  end
    
  authorizing do |user, permission|
    if user.is_a?(User) and permission == :create
      user.has_any_permission_to(:create, :performed_action, :on => Site.current) || false
    end || nil
  end
  
  authorizing do |user, permission|
    if user.is_a?(User)
      user.has_any_permission_to(permission, :performed_action, :on => organization) || false
    end || nil
  end

  def self.searcheable_fields
    [ "organization_type", "organization_id", unhideable_fields, hideable_fields ].flatten
  end

  def self.unhideable_fields
    [ "campaign_id"]
  end

  def self.hideable_fields
    [ 
      '/contact_params', 
      "contact_person", "contact_phone", "contact_email",
      '/performances_params', 
      "mobilization", "mobilization_pre", "mobilization_pre_description", "mobilization_to_who", "mobilization_description", 
      "mobilization_tour", "mobilization_tour_description", "used_material", "used_material_evaluation", "used_material_others", "used_material_others_description",
      "interesteds_comments", "interesteds_signs", "media_urls",
      '/other_aspects_params', 
      "activists_raising", "activists_raising_member_commited", "activists_raising_expert", "activists_raising_material_distrib", "activists_raising_interesteds",
      "gender_approach", "gender_approach_applied", "gender_approach_description", "gender_approach_tool_evaluation", 
      '/other_actions_params', 
      "media", "media_material_distrib", 
      "web_2_0", "web_2_0_specific_actions", 
      "institutional", "institutional_authorities_contact",
      "school_network", "school_network_description", 
      "society_movement", "society_movement_description", 
      "join_organizations", "join_organizations_description", 
      "other_info", "other_info_description", 
      '/valuation_params', 
      "positive_facts", "improve_facts"
    ]
  end

  def self.conditions_columns
    { :cont   => [ 
                  "custom_name", "contact_person", "contact_phone", "contact_email",
                  "mobilization_description", "mobilization_to_who", "used_material", "interesteds_comments", "interesteds_signs", "media_urls",
                  "media_material_distrib",
                  "activists_raising_member_commited", "activists_raising_material_distrib", "activists_raising_interesteds",
                  "web_2_0_specific_actions", "institutional_authorities_contact", "institutional_other",
                  "school_network_description", "society_movement_description", "join_organizations_description", "other_info_description", 
                  "positive_facts", "improve_facts"
                 ],
      :eq => ["organization_type", "organization_id", "campaign_id",
                  "mobilization", "media", "activists_raising", "web_2_0", "institutional", "school_network", "society_movement", "join_organizations", "other_info" ],
      :date   => [  ] }
  end
  
  def self.condition_type_for_column(column_name)
    ret = ''
    conditions_columns.each_pair do |key,value|
      ret = key if value.include?(column_name)
    end
    ret
  end

  def self.sort_for_csv(items)
    items
  end
  
  def self.organizations_for(type)
    case type
    when "LocalOrganization"
      organizations = LocalOrganization.orderby_name
    when "Autonomy"
      organizations = Autonomy.orderby_name
    else
      organizations = []
    end
    organizations
  end

  def self.column_translations
    { 
      'organization_type' => { :prefix => "activerecord.attributes.activists_collaboration", :transformations => ["underscore"] }
    }
  end

end
