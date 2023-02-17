# frozen_string_literal: true

require 'parking_ticket/configuration'
require 'parking_ticket/version'

# PayByPhone wrapper
require 'clients/adapter'
require 'clients/pay_by_phone/configuration'
require 'clients/pay_by_phone/adapter'
require 'clients/pay_by_phone/request'
require 'clients/pay_by_phone/client'

module ParkingTicket
  class Base
    class << self
      def valid_credentials?(adapter_name, username, password)
        adapter = Clients::PayByPhone::Adapter if adapter_name == 'pay_by_phone'
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

    def initialize(adapter_name, username, password)
      @adapter_name = adapter_name
      @username = username
      @password = password
    end

    def vehicles
      adapter.vehicles
    end

    def rate_options(zipcode, license_plate)
      adapter.rate_options(zipcode, license_plate)
    end

    def running_ticket(license_plate, zipcode)
      adapter.running_ticket(license_plate, zipcode)
    end

    def payment_methods
      adapter.payment_methods
    end

    def new_ticket(license_plate, zipcode, rate_option_id, quantity, time_unit, payment_method_id)
      adapter.new_ticket(license_plate, zipcode, rate_option_id, quantity, time_unit, payment_method_id)
    end

    private

    def load_adapter!
      return prepare_pay_by_phone_adapter! if @adapter_name == 'pay_by_phone'
      return prepare_easy_park_adapter! if @adapter_name == 'easy_park'

      raise Error, "Unhandled adapter : #{@adapter_name}"
    end

    def prepare_pay_by_phone_adapter!
      Clients::PayByPhone::Adapter.new(@username, @password)
    end

    def prepare_easy_park_adapter!
      raise Error, 'EasyPark will be handled in the next major release'
    end

    def adapter
      @adapter ||= load_adapter!
    end
  end
end
