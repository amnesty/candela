class Campaignaction < ActiveRecord::Base

  attr_accessible :organization_type, :organization_id, :campaign_id, :contact_person, :contact_phone, :contact_email, 
                  :mobilization, :mobilization_to_who, :mobilization_description, :used_material, :interesteds_comments, :interesteds_signs, 
                  :media_urls, :media, :media_material_distrib, :media_other, :activists_raising, :activists_raising_member_commited, :activists_raising_material_distrib, :activists_raising_interesteds, 
                  :web_2_0, :web_2_0_specific_actions, :institutional, :institutional_authorities_contact, :institutional_other, 
                  :school_network, :school_network_description, :society_movement, :society_movement_description, 
                  :join_organizations, :join_organizations_description, :other_info, :other_info_description,
                  :gender_approach, :gender_approach_description, :gender_approach_tool_evaluation, :positive_facts, :improve_facts

  include ActiveRecord::AIActiveRecord

  belongs_to :campaign

  belongs_to :organization, :polymorphic => true

  validates_format_of :contact_email, :with => REGEXP_EMAIL, :on => :save, :allow_blank => true
  
  validates_numericality_of :contact_phone, :allow_blank => true
  validates_length_of       :contact_phone, :allow_blank => true, :is => 9
  
  validates_presence_of :organization_id, :organization_type, :campaign_id
  
  validates_uniqueness_of :campaign_id, :scope => [ :organization_id, :organization_type ], :message => I18n.t('activerecord.errors.models.campaignaction.duplicated_action')
  
  scope :include_in,  { :include => [ :campaign ] }
  
   # Searchs Authorization NamedScope
  scope :can_see, lambda { |agent|
    options    = {}
    conditions = ''
    # whole site read talks permission                          
    if agent.is_a?(User) and not agent.has_any_permission_to(:read, :campaignaction, :on => Site.current)
      ps = 
        agent.performances.all(:include    => [ :role => :permissions ],
                               :conditions => [ 'permissions.objective = ? AND performances.stage_type IS NOT NULL AND performances.stage_type != ?', 'Campaignaction', 'Site' ]
                               )
      options[:conditions] = [ ps.map{ |p| "(campaignactions.organization_id = '#{ p.stage_id }' AND campaignactions.organization_type = '#{ p.stage_type }')" }.join(' OR ') ]
    end
    options
  }
  
  def to_title
    "#{ organization.to_title }/#{ campaign.name }"
  end
  
  def self.has_fast_search?
    false
  end
  
  
  authorizing do |user, permission|
    if user.is_a?(User) and permission == :create
      user.has_any_permission_to(:create, :campaignaction, :on => Site.current) || false
    end || nil
  end
  
  # By supporting organization relation in campaign
  authorizing do |user, permission|
    if user.is_a?(User)
      user.has_any_permission_to(permission, :campaignaction, :on => organization) || false
    end || nil
  end

  def self.searcheable_fields
    [unhideable_fields, hideable_fields, "organization_type", "organization_id" ].flatten
  end

  def self.unhideable_fields
#    [ "organization_type", "organization_id", "campaign_id"]
    [ "campaign_id"]
  end

  def self.hideable_fields
    [ 
      '/contact_params', 
      "contact_person", "contact_phone", "contact_email",
      '/performances_params', 
      "mobilization", "mobilization_description", "mobilization_to_who", "used_material", "interesteds_comments", "interesteds_signs", "media_urls",
      '/other_actions_params', 
      "media", "media_material_distrib", "media_other",
      "activists_raising", "activists_raising_member_commited", "activists_raising_material_distrib", "activists_raising_interesteds",
      "web_2_0", "web_2_0_specific_actions", 
      "institutional", "institutional_authorities_contact", "institutional_other",
      "school_network", "school_network_description", 
      "society_movement", "society_movement_description", 
      "join_organizations", "join_organizations_description", 
      "other_info", "other_info_description", 
      "/gender_approach", 
      "gender_approach", "gender_approach_description", "gender_approach_tool_evaluation", 
      '/valuation_params', 
      "positive_facts", "improve_facts"
    ]
  end

  def self.conditions_columns
    { :cont   => [ 
                  "contact_person", "contact_phone", "contact_email",
                  "mobilization_description", "mobilization_to_who", "used_material", "interesteds_comments", "interesteds_signs", "media_urls",
                  "media_material_distrib", "media_other", 
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
