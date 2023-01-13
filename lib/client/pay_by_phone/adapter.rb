module ParkingTicket
  module Client
    module PayByPhone
      class Adapter
        def initialize(configuration)
          @configuration = configuration
        end

        def covered?
          !!current_ticket
        end

        def current_ticket
          ticket = request.tickets(account_id).find do |ticket|
            ticket.dig('vehicle', 'licensePlate') == @configuration.license_plate
          end

          return unless ticket

          {
            starts_on: DateTime.parse(ticket['startTime']),
            ends_on: DateTime.parse(ticket['expireTime']),
            license_plate: ticket.dig('vehicle', 'licensePlate'),
            cost: ticket.dig('segments', 0, 'cost'),
            client: 'PayByPhone',
            client_ticket_id: ticket['parkingSessionId']
          }
        end

        def renew
          return if covered?

          quote = request.new_quote(rate_option_id, account_id)
          puts request.new_ticket(account_id, quote['parkingStartTime'], quote['quoteId'], payment_method_id)
        end

        private

        def request
          @request ||= Request.new(@configuration)
        end

        def account_id
          @account_id ||= request.accounts.dig(0, 'id')
        end

        def payment_method_id
          request.payment_methods['items'].find do |payment_method|
            payment_method['maskedCardNumber'] == @configuration.card_number
          end['id']
        end

        def rate_option_id
          request.rate_options(account_id).find do |rate_option|
            rate_option['type'] == 'RES' && rate_option['licensePlate'] == @configuration.license_plate
          end['rateOptionId']
        end
      end
    end
  end
end
