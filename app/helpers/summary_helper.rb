module SummaryHelper
  
  # Display classed div and acts as block
  def summary_view(options = {}, &block)
    content_tag :div, :class => 'nice_summary_div' do  
      content_tag :table, :class => "nice_summary_table", :cellspacing => "20" do
        capture(&block).html_safe
      end
    end
  end

  
  # Display classed td and acts as block
  @@current_section = 0
  def summary_section(options = {}, &block)
    
    @@current_section += 1
    
    id      = options[:id]      || "section_#{ @@current_section }"
    title   = options[:title]   || "Section number #{ @@current_section }"
    colpsan = options[:colspan] || 1 
        
    content_tag :td, :class=> "nice_summary_section", :id => id, :colspan => colpsan do
      content_tag(:h5, title) <<
      content_tag(:div, '', :class => "content clear") do
        capture(&block) #yield
      end
    end

  end
  
  def summary_label(text)
    content_tag :span, text, :class=> "nice_summary_label"
  end
  
  def summary_field(text)
    content_tag :span, (text.present? ? text : '---'), :class=> "nice_summary_field"
  end
  
  def summary_action(action, url, options)
    
    text   = options[:to]     || action
    object = options[:object] || current_site
    agent  = options[:agent]  || current_agent
    
    if object.authorize? action, :to => agent
      link_to t("form.buttons.#{ text }"), url, :class => "action_#{ text } with_icon left"
    else 
      ''
    end.html_safe
  end
  
  def summary_organization_header(object)
    
    uniq_name = object.class.name.underscore

    content_tag :tr do

      summary_section(:id => "#{ uniq_name }_contact_data", :title => t("#{ uniq_name  }.sections.contact")) do 

        content_tag(:div, :class => "actions") do
          summary_action(:update, edit_polymorphic_url(object, :section => "section_data"), { :to => :edit, :object => object }) <<
          summary_action(:read, polymorphic_url(object, :section => "section_data"), { :to => :show, :object => object })
        end <<

        [ 'address', 'email', 'phone', 'cp', 'city' ].collect do |field|
          content_tag :p, "#{summary_label(Gx.t_attr("#{ uniq_name }.#{ field }")) }: #{ summary_field object.send(field) }".html_safe
        end.join('').html_safe <<

        "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.province_id") }: #{ summary_field(object.province ? object.province.name : '') }</p>".html_safe <<

        if object.meeting_weekday.present? and object.meeting_weekday > 0
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.meeting_weekday")    }: #{ summary_field Gx.weekday_name(object.meeting_weekday - 1) }</p>".html_safe <<
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.meeting_frequency")  }: #{ summary_field object.meeting_frequency}</p>".html_safe <<
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.meeting_hours")      }: #{ summary_field object.meeting_hours }</p>".html_safe <<
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.meeting_venue_show") }: #{ summary_field object.meeting_venue}</p>".html_safe
        end

      end <<

      summary_section(:id => "#{ uniq_name }_other_addresses", :title => t("#{ uniq_name  }.sections.other_addresses")) do 
        
        content_tag(:div, :class => "actions") do
          summary_action(:update, edit_polymorphic_url(object, :section => "section_data"), { :to => :edit, :object => object }) <<
          summary_action(:read,   polymorphic_url(object, :section => "section_data"), { :to => :show, :object => object })
        end <<

        [ 'postal_address', 'postal_cp', 'postal_city' ].collect do |field|
          content_tag :p, "#{ summary_label(Gx.t_attr("#{ uniq_name }.#{ field }")) }: #{ summary_field object.send(field) }".html_safe
        end.join('').html_safe <<

        "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.postal_province_id") }: #{ summary_field(object.postal_province ? object.postal_province.name : '') }</p>".html_safe <<

        if object.same_address_for_deliver_and_postal?
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.delivery_address")    }: #{ summary_field Gx.t("#{ uniq_name }.same_address") }</p>".html_safe
        else

          [ 'delivery_address', 'delivery_cp', 'delivery_city' ].collect do |field|
            "<p>#{ summary_label(Gx.t_attr("#{ uniq_name }.#{ field }")) }: #{ summary_field object.send(field) }</p>"
          end.join('').html_safe <<      
          
          "<p>#{ summary_label Gx.t_attr("#{ uniq_name }.delivery_province_id") }: #{ summary_field(object.delivery_province ? object.delivery_province.name : '') }</p>".html_safe <<
          
          [ 'delivery_contact', 'delivery_phone', 'delivery_hours' ].collect do |field|
            "<p>#{ summary_label(Gx.t_attr("#{ uniq_name }.#{ field }")) }: #{ summary_field object.send(field) }</p>"
          end.join('').html_safe      
        end

      end

    end

  end 

  def summary_notes_section_for(object)
    
    uniq_name = object.class.model_name.underscore
    new_note  = object.notes.new
    object.notes.delete new_note
        
    if new_note.authorize? :read, :to => current_agent
      
      content_tag :tr do
        summary_section(:id => "#{ uniq_name }_section_notes", :colspan => 2, :title => Gx.t_attr("#{ uniq_name }.sections.notes")) do 

          content_tag(:div, :class => "actions") do
            summary_action(:create, new_polymorphic_url([ object, new_note ]), { :object => new_note }) <<
            summary_action(:read,   polymorphic_url([ object, :notes ]),       { :object => new_note, :to => :show })
          end <<

          if object.notes.empty?
            t("#{ uniq_name }.notes.none")
          else
            notes_parents_view(object.notes.only_parents)
          end

        end 
      end 
    end
  end
  
  def summary_collaborations_for_section_for(organization)
   
    uniq_name = organization.class.name.underscore
    new_coll  = organization.activists_collaborations.new
    organization.activists_collaborations.delete new_coll
    # FIXME
    new_coll.organization_type = organization.class.name
    ret       = '' 

    if new_coll.authorize? :read, :to => current_agent
      
      collaborations = organization.activists_collaborations.orderby_name
#      members        = collaborations.select{ |c| c.is_member    }
#      supporters     = collaborations.select{ |c| c.is_support   }
#      casuals        = collaborations.select{ |c| c.is_casual    }
#      experts        = collaborations.select{ |c| c.is_expertise }
#      ordered_colls  = [ { :member => members }, { :support =>  supporters }, { :casual =>  casuals }, { :expertise =>  experts } ]

      content_tag :tr do
        summary_section(:id => "#{ uniq_name }_collaborations", :colspan => 2, :title => t("#{ uniq_name }.sections.collaborations")) do 


         form_tag '#', :method => :get do
           ''.tap do |html|

              if organization.is_a?(Autonomy)
                aatt = current_user.agent_performances.where(:stage_type => 'AutonomicTeam').collect(&:stage).select{|t|t.autonomy == organization}.uniq
                default_team = (aatt.count == 1 ? aatt.first : nil) 
                html << autonomic_team_options_for_select(organization, default_team) 
              end
              html << status_options_for_select
              html << type_options_for_select(uniq_name)

              html << "<ul  id='organization_activists_list' >"
              collaborations.each do |collaboration|

                collaboration_classes = ["collaboration_state_#{collaboration.activist_status.name}", collaboration.guess_collaboration_type, "status_#{collaboration.activist_status_id}"]
                collaboration_classes += collaboration.autonomic_teams.collect{|team| "autonomic_team_#{team.id}"} if organization.is_a?(Autonomy)
                html << "<li class= '#{collaboration_classes.join(' ')}'>"

                html << "#{ display_activist_collaborations_marks(collaboration) }"
                text_args = { :collaboration_type => link_to( h(collaboration.kind),activist_activists_collaboration_path(collaboration.activist, collaboration) ),
                              :organization       => link_to( h(collaboration.organization_name), collaboration_organization_path(collaboration)),
                              :join_at            => localize(collaboration.join_at.to_date),
                              :activist           => link_to( h(collaboration.activist.second_first_name), activist_path(collaboration.activist) ),
                              :email              => collaboration.activist.email ? mail_to(collaboration.activist.email) : "",
                              :phone              => "#{ collaboration.activist.phone ? collaboration.activist.phone : "---" }, #{ collaboration.activist.mobile_phone ? collaboration.activist.mobile_phone : "---" }",
                              :responsibility     => collaboration.h_responsibilities }
                        
                text_args[:expertise] = collaboration.h_expertises if collaboration.is_expertise 
                html << t("activists_collaboration.texts.#{ collaboration.guess_collaboration_type }_collaborations", text_args)
                html << '</li>'
              end
              html << '</ul>'

              active_filters = ["'status'","'type'"]
              active_filters.push "'autonomic_team'" if organization.is_a?(Autonomy)
              html << javascript_tag("$(document).ready(function(){ initActivistFilters([#{active_filters.join(',')}]); });")
            end.html_safe
          end

        end
      end

    end
  end
  
  def summary_autonomic_teams_for(autonomy)

    uniq_name = autonomy.class.name.underscore
    content_tag :tr do
      summary_section(:id => "#{ uniq_name }_autonomic_teams", :colspan => 2, :title => t("#{ uniq_name  }.sections.autonomic_teams")) do 
        form_tag (url_for autonomy), :method => :get do
          content_tag :ul, :id => "#{ uniq_name }_autonomic_teams_list" do
            autonomy.autonomic_teams.inject('') do |html,team| 
              html << content_tag(:li, team.name)
            end.html_safe
          end
        end
      end
    end
  end

  def summary_organizations_onoffs_for(organization, options = {})
    
    uniq_name = organization.class.name.underscore
    new_on_off  = organization.organization_on_offs.new
    organization.organization_on_offs.delete new_on_off

    options =  { :id => "#{ uniq_name }_section_local_organization_onoffs", :title => t("#{ uniq_name }.sections.onoffs") }.merge(options)
    
    summary_section(options) do 
    
      content_tag(:div, :class => "actions") do
        (organization.enabled ? summary_action(:update, new_polymorphic_url( [ organization, new_on_off ], { :disable => true }), { :to => :leave,  :object => organization }) : "").html_safe <<
        summary_action(:update,   polymorphic_url([ organization, new_on_off ]), { :to => :edit, :object => organization })
      end <<

      if organization.organization_on_offs.empty?
        t("#{ uniq_name }.organization_on_offs.none")
      else
        content_tag(:ul) do
          organization.organization_on_offs.collect do |onoff|
              content_tag :li, onoff.h
          end.join('').html_safe
        end
      end
    end
  end
  
  def summary_talks_section_for(organization)
   
    uniq_name = organization.class.name.underscore
    new_talk  = organization.talks.new
    organization.talks.delete new_talk 

    summary_section(:id => "#{ uniq_name }_section_local_organization_talks", :title => t("#{ uniq_name }.sections.talks")) do 

      content_tag(:div, :class => "actions") do
        summary_action(:create,   new_polymorphic_url([ organization, new_talk ]), { :object => new_talk }) <<
        summary_action(:update,   polymorphic_url([ organization, new_talk ]),     { :to => :edit, :object => new_talk }) <<
        summary_action(:read,     polymorphic_url([ organization, new_talk ]),     { :to => :show, :object => new_talk })
      end <<

      if organization.talks.empty?
        t("#{ uniq_name }.talks.none").html_safe
      else
        content_tag(:ul) do
          organization.talks.collect do |talk|
            "<li>#{ t('talk.texts.complete',
                              :name => h(talk.name),
                              :address => h(talk.address),
                              :date => I18n.localize(talk.date.to_date),
                              :hours => h(talk.hours),
                              :seats => h(talk.seats),
                              :organization => h(talk.organization.name)) }</li>"
          end.join('').html_safe
        end
      end
    end
  end
  
  def summary_campaignactions_section_for(organization)

    uniq_name  = organization.class.name.underscore
    new_action = organization.campaignactions.new
    organization.campaignactions.delete new_action

    summary_section(:id => "#{ uniq_name }_section_local_organization_campaignactions", :title => t("#{ uniq_name }.sections.campaignactions")) do 

      content_tag(:div, :class => "actions") do
        summary_action(:create,   new_polymorphic_url([ organization, new_action ]), { :to => :create, :object => new_action }) <<
        summary_action(:read,     polymorphic_url([ organization, new_action ]),     { :to => :show, :object => organization })
      end <<

      if organization.campaignactions.empty?
        t("campaignaction.none")
      else
        content_tag(:ul) do
          organization.campaignactions.collect do |action|
            "<li>#{ link_to action.campaign.name, action }</li>"
          end.join('').html_safe
        end
      end
    end
  end

  def summary_hr_schools_section_for(organization, options = {})

    uniq_name  = organization.class.name.underscore

    options[:id] = "#{ uniq_name }_section_hr_schools"
    options[:title] = t("#{ uniq_name }.sections.hr_schools")

    summary_section(options) do 

      content_tag(:table, :width => '100%') do

        content_tag(:tr) do
          content_tag(:th, t("#{ uniq_name }.sections.assigned_hr_schools")) +
          content_tag(:th, t("#{ uniq_name }.sections.near_hr_schools"))
        end <<

        content_tag(:tr) do
          content_tag(:td) do
            if organization.assigned_hr_schools.empty?
              t("hr_school.none")
            else
              content_tag(:ul) do
                organization.assigned_hr_schools.collect do |school|
                  "<li>#{ link_to school.name, school }</li>"
                end.join('').html_safe
              end
            end
          end <<
          content_tag(:td) do
            if organization.near_hr_schools.empty?
              t("hr_school.none")
            else
              content_tag(:ul) do
                organization.near_hr_schools.collect do |school|
                  "<li>#{ link_to school.name, school }</li>"
                end.join('').html_safe
              end
            end
          end
        end
      end
    end
  end

end
