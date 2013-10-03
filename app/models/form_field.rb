class FormField

  @@multi_field_separators = '
',','
  def initialize(klass,field_name)
    @klass = klass
    @field_name = convert_field_name_id_to_relation(klass,field_name)

    @field = self.class.cascaded_association_from_name(klass,@field_name) || self.class.column_from_name(klass,@field_name) || self.class.association_from_name(klass,@field_name) || self.class.phrase_translation_from_name(klass,@field_name)
  end

  def klass
    @klass
  end

  def field_name
    @field_name
  end

  def field
    @field
  end


  # Removes phrase translations (strings begginning with '/') from a list
  def self.removePhraseTranslations(list)
    list.collect{|elem| elem unless elem.start_with?('/')}.compact
  end 

# Instance methods: field analysis

  def is_phrase_translation?
    (@field.class == String) || (@field.class == ActiveSupport::SafeBuffer)
  end

  def is_cascaded_association?
    @field.class == Array 
  end

  def is_direct_association?
    @field.class.name.end_with? 'AssociationReflection'
  end

  def is_column?
    @field.class.name.end_with? 'Column'
#    !(is_cascaded_association?(@field) || is_direct_association?(@field))
  end

  def needs_translation?
    @klass.respond_to?('column_translations') && @klass.column_translations.has_key?(@field_name)
  end

# Instance method for field info retrieval

  def form_field_name
    if is_cascaded_association?
      relation_klass = @field[0]
      relation_field = @field[1]        
      "#{relation_klass}.#{ relation_field.form_field_name }"
    elsif is_direct_association?
      @field.collection? ? "#{ @field.name.to_s.singularize }_ids" : "#{ @field.name.to_s }_id"
    elsif is_column?
      @field.name
    else
      Rails.logger.error "FormField.form_field_name : Unknown field type for field named '#{field_name}'"
    end
  end

  def translated_field_name
    klass_params_name = @klass.name.underscore.pluralize
    if is_cascaded_association?   
      Gx.t_attr(form_field_name)
    elsif is_direct_association?
      Gx.t_attr("#{@klass.name.underscore}.#{ form_field_name }")
    elsif is_column?
      Gx.t_attr("#{@klass.name.underscore}.#{ form_field_name }")
    else
      Rails.logger.error "FormField.translated_field_name : Unknown field type for field named '#{field_name}'"
    end
  end

  def translate_field_value(value)
    if needs_translation?      
      if @klass.column_translations[@field.name].has_key?(:command)
        @klass.column_translations[@field.name][:command].call(value)
      else
        @klass.column_translations[@field.name][:transformations].each {|command| value = eval("'#{value}'.#{command}") }
        value.blank? ? '' : Gx.t("#{@klass.column_translations[@field.name][:prefix]}.#{value}") 
      end
    else
      value
    end
  end

  # New version of gx.eval_field, intended to deal with reflection (fields inherited from relations)
  # Evaluates a field. If it is a foreign key, evaluates the value of the key, taking care of nil values.
  def self.evaluate_field(resource, field_name, translate_value = true, cur_assoc_level = 0)
    ret = ''
    ff = FormField.new(resource.class,field_name)

    if ff.is_cascaded_association?
      foreign_object = resource.send(ff.field[0].pluralize)
      if (foreign_object.class == Array)
#        ret = foreign_object.collect{|o| o.send(field[1].name)}.join(', ')
        ret = foreign_object.collect{|o| evaluate_field(o,ff.field[1].field.name,translate_value,cur_assoc_level+1)}.join(@@multi_field_separators[cur_assoc_level])
      else
        ret = foreign_object.send(ff.field[1].field.name)
      end

    elsif ff.is_direct_association?

      if ff.field.macro == :has_and_belongs_to_many
        ret =  resource.send(ff.field_name).map(&:name).join(@@multi_field_separators[cur_assoc_level])

      elsif ff.field.macro == :belongs_to
        foreign_object = resource.send(ff.field_name)
        ret = foreign_object.nil? ? "" : foreign_object.name

      else
        ret = "Field '#{ field_name }' can't be evaluated: Association '#{ ff.field.macro.to_s }' not yet implemented." #TODO: Evaluate other kinds of association or (better if possible) split by collection/no collection
      end

    elsif ff.is_column?
#      if field_name.match(/_id/)
#        foreign_object = resource.send(field_name.gsub(/_id$/,''))
#        ret = foreign_object.nil? ? "" : foreign_object.name
#      else
        ret = resource.send(ff.field_name)
#      end

    else
      Rails.logger.error "FormField.evaluate_field : Unknown class or field type for field named '#{field_name}'"
      ret = "FormField.evaluate_field : Unknown class or field type for field named '#{field_name}'"
    end

    translate_value ? ff.translate_field_value(ret) : ret
  end

  #TODO: Method for rendering a form element from field data. ¿should it be in a helper, in a partial...?
  def render_form_control

    returning "" do |html|    
      # Complex relation (attribute from another table)
      if @field.class == Array 
        html << "Cascaded relation form controls: ToDo"

      # Relation (relation attribute from this table)
      elsif @field.class.name.end_with? 'AssociationReflection'

        if @field.macro == :has_and_belongs_to_many
          relation_model_klass.all.each do |s|
            html << "<p class='left small_margin small'>"
            html << check_box_tag("#{@klass}[#{ relation_model }_by_ids][#{ s.id }]",
                                  "1",
                                  (params[@klass.to_sym] && params[@klass.to_sym]["#{ relation_model }_by_ids"] && params[@klass.to_sym]["#{ relation_model }_by_ids"]["#{ s.id }"])) + s.name
            html << "</p>"
            end

        elsif @field.macro == :belongs_to

        else
          html << "Field '#{ @field_name }' can't be rendered: Association '#{ @field.macro.to_s }' not yet implemented."
        end

      # Column (column attribute from this table)
      else
        search_logic_field_name = "#{ @field.name }_#{ @klass.condition_type_for_column(@field.name) }"

        if @field.type == :text
          html << text_area_tag("#{@klass}[#{ search_logic_field_name }]", ((params[@klass.to_sym] && params[@klass.to_sym]["#{ search_logic_field_name }"]) ? params[@klass.to_sym]["#{ search_logic_field_name }"] : ''))

        end
      end
    end
  end

private

  def convert_field_name_id_to_relation(klass,field_name)
    field_name.is_a?(Symbol) ? field_name = field_name.to_s : nil
    if field_name.last(3) == '_id' and klass.column_names.include?(field_name) and klass.columns.select{|c| c.name == field_name }.first.type == :integer
      field_name = field_name[0..-4]
    elsif field_name.last(4) == '_ids' and klass.instance_methods.include?(field_name[0..-5].pluralize) 
      field_name = field_name[0..-5].pluralize
    end
    field_name
  end

  # Constructors for each field type

  def self.phrase_translation_from_name(klass,field_name)
    field_name.start_with?('/') ? Gx.t("#{klass.name.underscore}.search.#{field_name[1..-1]}") : nil
  end

  def self.association_from_name(klass,field_name)
    klass.reflect_on_association(field_name.to_sym)
  end

  def self.column_from_name(klass,field_name)
    klass.respond_to?('columns') ? klass.columns.select{|c| c.name == field_name }.first : nil
  end

  def self.cascaded_association_from_name(klass,field_name)
    elems = field_name.split('.')
    elems.length > 1 ? [ elems[0], FormField.new(elems[0].camelize.constantize,elems[1]) ] : nil
  end
end
