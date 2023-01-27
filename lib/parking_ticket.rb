# frozen_string_literal: true

require 'parking_ticket/configuration'
require 'parking_ticket/version'

# PayByPhone wrapper
require 'client/pay_by_phone/configuration'
require 'client/pay_by_phone/adapter'
require 'client/pay_by_phone/request'

module ParkingTicket
  class Base
    class << self
      def valid_credentials?(adapter_name, username, password)
        adapter = Client::PayByPhone::Adapter if adapter_name == 'pay_by_phone'
        raise Error, 'EasyPark will be handled in the next major release' if adapter_name == 'easy_park'
        raise Error, "Unhandled adapter : #{adapter_name}" unless adapter

        adapter.valid_credentials?(username, password)
      end

      def config
        yield(self)
      end

      attr_accessor :ticket_format

      def format_ticket(ticket)
        return unless ticket_format

        ticket_format.each_with_object({}) do |element, acumulator|
          if element.is_a?(Hash)
            original_key = element.keys.first
            target_key = element.values.first
            acumulator[target_key] = ticket[original_key]
          else
            acumulator[element] = ticket[element]
          end
        end
      end
    end
    attr_reader :configuration

    class Error < StandardError
    end

    def initialize(adapter_name, configuration_attributes)
      @adapter_name = adapter_name
      @configuration_attributes = configuration_attributes
      @result = {}
    end

    def adapter
      @adapter ||= load_adapter!
    end

    def renew
      adapter.renew unless current_ticket
    end

    def current_ticket
      ticket = adapter.current_ticket
      ticket = self.class.format_ticket(ticket) if self.class.ticket_format
      ticket
    end

    private

    def load_adapter!
      return prepare_pay_by_phone_adapter! if @adapter_name == 'pay_by_phone'
      return prepare_easy_park_adapter! if @adapter_name == 'easy_park'

      raise Error, "Unhandled adapter : #{@adapter_name}"
    end

    def prepare_pay_by_phone_adapter!
      configuration = pay_by_phone_configuration
      return Client::PayByPhone::Adapter.new(configuration) if configuration.completed?

      raise Error, 'Uncompleted configuration'
    end

    def pay_by_phone_configuration
      Client::PayByPhone::Configuration.new do |config|
        config.username = @configuration_attributes[:username]
        config.password = @configuration_attributes[:password]
        config.license_plate = @configuration_attributes[:license_plate]
        config.zipcode = @configuration_attributes[:zipcode]
        config.card_number = @configuration_attributes[:card_number]
      end
    end

    def prepare_easy_park_adapter!
      raise Error, 'EasyPark will be handled in the next major release'
    end
  end
end
