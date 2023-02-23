module ParkingTicket
  module Clients
    module PayByPhone
      class Adapter < Clients::Adapter
        ACCEPTED_TIME_UNIT_MAPPER = {
          'Days' => 'days',
          'Minutes' => 'minutes',
          'Hours' => 'hours'
        }.freeze

        PAYMENT_CARD_TYPE_MAPPER = {
          'MasterCard' => 'master_card',
          'Visa' => 'visa'
        }.freeze

        private

        def fetch_and_map_vehicles
          client.vehicles.map do |vehicle|
            {
              client_internal_id: vehicle['vehicleId'],
              license_plate: vehicle['licensePlate'],
              type: vehicle['type']
            }
          end
        end

        def fetch_and_map_rate_options(zipcode, license_plate)
          client.rate_options(zipcode, license_plate).map do |rate_option|
            mapped_time_units = rate_option['acceptedTimeUnits'].map do |accepted_time_unit|
              ACCEPTED_TIME_UNIT_MAPPER[accepted_time_unit]
            end
            {
              client_internal_id: rate_option['rateOptionId'],
              name: rate_option['name'],
              type: rate_option['type'],
              accepted_time_units: mapped_time_units
            }
          end
        end

        def fetch_and_map_running_ticket(license_plate, zipcode)
          client.running_tickets.filter do |ticket|
            ticket.dig('vehicle', 'licensePlate') == license_plate && ticket['locationId'] == zipcode
          end.map do |ticket|
            {
              client_internal_id: ticket['parkingSessionId'],
              starts_on: DateTime.parse(ticket['startTime']),
              ends_on: DateTime.parse(ticket['expireTime']),
              license_plate: ticket.dig('vehicle', 'licensePlate'),
              cost: ticket.dig('segments', 0, 'cost'),
              client: 'PayByPhone'
            }
          end.first
        end

        def request_new_ticket(license_plate:, zipcode:, rate_option_client_internal_id:, quantity:, time_unit:, payment_method_id:)
          mapped_time_unit = ACCEPTED_TIME_UNIT_MAPPER.key(time_unit)

          quote = fetch_and_map_quote(rate_option_client_internal_id, zipcode, license_plate, quantity,
                                      time_unit)

          client.new_ticket(
            license_plate: license_plate,
            zipcode: zipcode,
            rate_option_client_internal_id: rate_option_client_internal_id,
            quantity: quantity,
            time_unit: mapped_time_unit,
            quote_client_internal_id: quote[:client_internal_id],
            starts_on: quote[:starts_on],
            payment_method_id: payment_method_id
          )
        end

        def fetch_and_map_payment_methods
          client.payment_methods['items'].map do |payment_method|
            {
              client_internal_id: payment_method['id'],
              anonymised_card_number: payment_method['maskedCardNumber'][-4..],
              payment_card_type: PAYMENT_CARD_TYPE_MAPPER[payment_method['paymentCardType']]
            }
          end
        end

        def fetch_and_map_quote(rate_option_id, zipcode, license_plate, quantity, time_unit)
          mapped_time_unit = ACCEPTED_TIME_UNIT_MAPPER.key(time_unit)
          fetched_quote = client.quote(rate_option_id, zipcode, license_plate, quantity, mapped_time_unit)

          {
            client_internal_id: fetched_quote['quoteId'],
            starts_on: fetched_quote['parkingStartTime'],
            ends_on: fetched_quote['parkingExpiryTime'],
            cost: fetched_quote.dig('totalCost', 'amount')
          }
        end
      end
    end
  end
end
