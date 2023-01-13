module ParkingTicket
  class Configuration
    def self.attr_required(*configuration_keys)
      define_method('attr_required') do
        configuration_keys
      end
      configuration_keys.each do |configuration_key|
        define_method configuration_key.to_s do
          instance_variable_get("@#{configuration_key}")
        end
        define_method "#{configuration_key}=" do |value|
          instance_variable_set("@#{configuration_key}", value)
        end
      end
    end

    def initialize
      @attr_required = defined?(attr_required) ? attr_required : []
      yield(self)
    end

    def completed?
      @attr_required.all? { |attribute_required| instance_variable_get("@#{attribute_required}") }
    end
  end
end
