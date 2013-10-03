class City < ActiveRecord::Base

    def self.translate_bd_string_to_city_name(str)
      begin
        city = find_by_id(str) || find_by_name(str)
        if city
          city.name
        elsif str == Gx.t('country.select_cp_or_province')
          ''
        else
          str
        end
      rescue
        str
      end
    end

end
