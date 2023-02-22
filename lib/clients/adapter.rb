module ParkingTicket
  module Clients
    class Adapter
      class << self
        def parent_module
          const_get(name.split('::')[0..-2].join('::'))
        end

        def valid_credentials?(username, password)
          parent_module::Client.auth(username, password).status == 200
        end
      end
      class Error < StandardError
      end

      def initialize(username, password)
        @username = username
        @password = password
      end

      def vehicles
        raise_invalid_credentials! unless valid_credentials?
        fetch_and_map_vehicles
      end

      def rate_options(zipcode, license_plate)
        raise_invalid_credentials! unless valid_credentials?
        fetch_and_map_rate_options(zipcode, license_plate)
      end

      def running_ticket(license_plate, zipcode)
        raise_invalid_credentials! unless valid_credentials?
        fetch_and_map_running_ticket(license_plate, zipcode)
      end

      def payment_methods
        raise_invalid_credentials! unless valid_credentials?
        fetch_and_map_payment_methods
      end

      def quote(rate_option_id, zipcode, license_plate, quantity, time_unit)
        raise_invalid_credentials! unless valid_credentials?
        fetch_and_map_quote(rate_option_id, zipcode, license_plate, quantity, time_unit)
      end

      def new_ticket(license_plate, zipcode, rate_option_id, quantity, time_unit, payment_method_id:)
        raise_invalid_credentials! unless valid_credentials?
        return if running_ticket(license_plate, zipcode)

        request_new_ticket(license_plate, zipcode, rate_option_id, quantity, time_unit,
                           payment_method_id: payment_method_id)
      end

      private

      def client
        @client ||= self.class.parent_module::Client.new(@username, @password)
      end

      def valid_credentials?
        @valid_credentials ||= self.class.valid_credentials?(@username, @password)
      end

      def raise_invalid_credentials!
        raise Error, 'Adapter credentials are not valid'
      end
    end
  end
end
