# encoding: utf-8
module Gx

  # Modules are in fact, classes, so we reopen this module and add a few functions
  class << self

    # http://www.geekpedia.com/code109_Extract-Age-from-Birth-Date.html
    def age(bDate) #bDate must be in the date-time format
      age = Date.today.year - bDate.year
      if Date.today.month < bDate.month ||
          (Date.today.month == bDate.month && bDate.day > Date.today.day)
        age = age - 1
      end
      age
    end

    # Addresses can be either completely empty or completely full
    def validate_address( cp, province_id, city )
      if cp.to_i == 0 && province_id.to_i == 0 &&
        [ "", t("country.select_cp_or_province"), t("country.select_a_city")].index(city)
       return [ true, nil ]
      elsif cp.to_i == 0 || province_id.to_i == 0 ||
          ["", t("country.select_cp_or_province"), t("country.select_a_city")].index(city)
        return [ false, :address_can_not_be_empty ]
      else
        return [ true, nil ]
      end
    end

    def regexp_acutes(query)
      case query
        when Array
          query.collect{|elem| regexp_acutes(elem)}
        when String
          q = query.gsub(/[AaÁáÂâÄäÀà]/, "[AaÁáÂâÄäÀà]")
          q.gsub!(/[EeÉéÊêËëÈè]/, "[EeÉéÊêËëÈè]")
          q.gsub!(/[IiÍíÎîÏïÌì]/, "[IiÍíÎîÏïÌì]")
          q.gsub!(/[OoÓóÔôÖöÒò]/, "[OoÓóÔôÖöÒò]")
          q.gsub!(/[UuÚúÛûÜüÙù]/, "[UuÚúÛûÜüÙù]")
          return q
      end  

    end

    def remove_acutes(string)
      acutes_chars = { 'á' => 'a', 'é' => 'e', 'í' => 'i', 'ó' => 'o', 'ú' => 'u',
                        'Á' => 'a', 'É' => 'e', 'Í' => 'i', 'Ó' => 'o', 'Ú' => 'u' }
      string = string.downcase
      acutes_chars.each_pair do |key,value|
        string = string.gsub(/["#{ key }"]/, "#{ value }")
      end
      string
    end

    #[FIXME] TextHelper.highlight, modififed to accept regular expressions. I removed sanitize and Regexp.escape, and added /i flag to gsub. Is there a better way to do this?
      def highlight_regexp(text, phrases, *args)
        options = args.extract_options!
        unless args.empty?
          options[:highlighter] = args[0] || '<strong class="highlight">\1</strong>'
        end
        options.reverse_merge!(:highlighter => '<strong class="highlight">\1</strong>')

#        text = sanitize(text) unless options[:sanitize] == false #TODO: Here, 'text' is our own page. If, anyway, it makes sense to sanitize, the SanitizeHelper must be included.
        if text.blank? || phrases.blank?
          text
        else
#          match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
          match = Array(phrases).map { |p| p }.join('|')
          text.gsub(/(#{match})(?![^<]*?>)/i, options[:highlighter])
        end.html_safe
      end



    # string.capitalize converts the rest of the string to lower case
    def proper(text)
      if text && text.length > 0
        return text[0,1].capitalize + text[1..-1]
      end
      return ""
    end

    # Translates a string. If not found, tries an alternative location
    def t(text, optional_location = nil)
      translated = I18n.t(text)
      if optional_location and translated.index( "translation missing" ) != nil
        translated_save = translated
        parts = text.split(".")
        if parts
          translated = I18n.t( optional_location + "." + parts[-1])
          unless translated.index( "translation missing" ) == nil
            # To show the original translation index
            translated = translated_save
          end
        end
      end
      translated
    end

    def t_attr(text)
      I18n.t "activerecord.attributes." + text
    end

    # Translates a model name, guessing if it must pluralize.
    # FIXME: Modify use of tranlations to allow a better model translation method
    def t_model(text)
#      I18n.t("activerecord.models." + text.gsub("_", " "))
      if Object.const_defined?(text.camelize)
        text.camelize.constantize.model_name.human(:count=>1)
      elsif Object.const_defined?(text.singularize.camelize)
        text.singularize.camelize.constantize.model_name.human(:count=>2)
      else
        I18n.t "activerecord.models.#{text}"
      end
    end

    # In r2r, error messages for field validations are first looked up in
    # es, activerecord, errors, models, model, attributes, field
    # and if not found, then in
    # es, activerecord, errors, messages
    # The %{model} parameter is also translated looking up in es, activerecord, models
    def t_error(text, options = {})
      model_and_error = text.split(".")
      if model_and_error.size > 2
      I18n.t "activerecord.errors.models.#{model_and_error[0]}.attributes.#{model_and_error[1]}.#{model_and_error[2]}", options
      elsif model_and_error.size > 1
        I18n.t "activerecord.errors.models.#{model_and_error[0]}." + model_and_error[1], options
      else
        I18n.t "activerecord.errors.messages.#{model_and_error[0]}", options
      end
    end

    def t_action(text)
      model_and_action = text.split(".")
      if model_and_action[1] == "index" || model_and_action[1] == "toindex"
        I18n.t "form.actions." + model_and_action[1], :model => t_model("#{model_and_action[0].pluralize}")
      else
        I18n.t "form.actions." + model_and_action[1], :model => t_model(model_and_action[0])
      end
    end

    def t_confirm_delete(model)
      I18n.t "form.confirm_delete", :model => I18n.t("activerecord.models." + model.class.name.underscore.gsub("_", " ") )
    end

    def t_boolean(abool)
      # FIXME es.yml does not work
      if abool.nil? || !abool
        return "No"
      else
        return "Sí"
      end
    end

    def weekday_name(day)
      t("date.day_names")[day]
    end

    def reset_list_style
      $LIST_STYLE_ROW = 0
    end

    def list_style
      if $LIST_STYLE_ROW == 0
        $LIST_STYLE_ROW = 1
      else
        $LIST_STYLE_ROW = 0
      end
      return "list_style_#{$LIST_STYLE_ROW}"
    end

    # Checks whether an user has some permission on some objective, defined in the roles table
    def user_can( current_agent, permission, objective )
      current_agent.performances.each do |p|
        # If a user has a performance whose stage_type is not a Site, it must see that stage: LocalCorganizsation, Autonomy, etc.
        if p.stage_type == objective.classify || p.stage_type == 'Site'
          return true
        end
        if p.role.permissions.map(&:to_array).include?( [permission, objective.classify.to_sym ] )
          return true
        end
      end
      return false
    end

    def h_enabled(enabled)
      if enabled
        I18n.t('words.enabled')
      else
        I18n.t('words.disabled')
      end
    end

    # Bu. Module is unnamed. Ruby is complaining when is_a? method is used
    def to_csv(element)
      e = element.class.name
      case e
      when "Nil"
        ret = ''
      when "Date","DateTime" #TODO: Find a way to include DateTimeWithZone and other kinds of dates and times...
        ret = I18n.localize(element)
      when "String"
        object = '' if element == I18n.t('country.select_cp_or_province')
        ret = element
      else
        ret = element.to_s
      end

      ret.empty? ? ret : ('"' + ret.gsub('"', '“') + '"')
    end

    # Returns: nil if value is nil or empty string,  true on a defined set of values , false otherwise
    def to_boolean(value)
      (value.nil? || (value.is_a?(String) && value.empty?)) ? nil : value.to_s.match(/(true|t|yes|y|1)$/i) != nil
    end

  end # class << self


end # Module gx
