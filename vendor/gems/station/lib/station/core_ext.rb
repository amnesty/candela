unless Symbol.instance_methods.include? 'to_class'
  Symbol.class_eval do
    def to_class
      self.to_s.classify.constantize
    end
  end
end

unless ActionDispatch::Routing::PolymorphicRoutes.respond_to?(:polymorphic_url_with_container)
  ActionDispatch::Routing::PolymorphicRoutes.module_eval do
    def polymorphic_url_with_container(record_or_hash_or_array, options = {})
      if options.delete(:container) == false
        return polymorphic_url_without_container(record_or_hash_or_array, options)
      end

      rha_with_container =
        case record_or_hash_or_array
        when Array
          unshift_container record_or_hash_or_array.dup
        when Hash
          record_or_hash_or_array.dup
        else
          unshift_container [ record_or_hash_or_array ]
        end

      polymorphic_url_without_container(rha_with_container, options)
    end
    alias_method_chain :polymorphic_url, :container

    def unshift_container(array)
      if array.first.respond_to?(:container)
        array.unshift(array.first.container)
        unshift_container(array)
      else
        array
      end
    end
  end
end



