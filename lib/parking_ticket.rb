# frozen_string_literal: true

require 'parking_ticket/configuration'
require 'parking_ticket/version'

# PayByPhone wrapper
require 'client/pay_by_phone/configuration'
require 'client/pay_by_phone/adapter'
require 'client/pay_by_phone/request'

module ParkingTicket
  class Base
    attr_reader :configuration

    class Error < StandardError
    end

    def initialize(adapter_name, configuration_attributes)
      @adapter_name = adapter_name
      @configuration_attributes = configuration_attributes
    end

    def adapter
      @adapter ||= load_adapter!
    end

    def renew
      if current_ticket
        puts '❌ Can not renew ticket as already covered by a ticket at this time'
      else
        puts '🔄 Renewing ticket'
        adapter.renew
        puts '✅ Ticket renewed'
      end
    end

    def current_ticket
      puts '🕵️ Retrieving current_ticket'
      adapter.current_ticket
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
