require 'faraday'
module ParkingTicket
  module Clients
    module PayByPhone
      class Client
        class << self
          def rate_options(token, account_id, zipcode, license_plate)
            connection(token).get("/parking/locations/#{zipcode}/rateOptions",
                                  {
                                    parkingAccountId: account_id,
                                    licensePlate: license_plate
                                  }).body
          end

          def vehicles(token)
            connection(token).get('/identity/profileservice/v1/members/vehicles/paybyphone').body
          end

          def auth(username, password)
            conn = Faraday.new('https://auth.paybyphoneapis.com') do |f|
              f.response :json
            end
            conn.post(
              '/token',
              URI.encode_www_form({
                                    grant_type: 'password',
                                    username: username,
                                    password: password,
                                    client_id: 'paybyphone_web'
                                  }),
              {
                'Accept' => 'application/json, text/plain, */*',
                'X-Pbp-ClientType' => 'WebApp'
              }
            )
          end

          def account_id(token)
            connection(token).get('/parking/accounts').body.dig(0, 'id')
          end

          def running_tickets(token, account_id)
            connection(token).get("/parking/accounts/#{account_id}/sessions?periodType=Current").body
          end

          def quote(token, account_id, rate_option_id, zipcode, license_plate, quantity, time_unit)
            connection(token).get(
              "/parking/accounts/#{account_id}/quote",
              {
                locationId: zipcode,
                licensePlate: license_plate,
                rateOptionId: rate_option_id,
                durationTimeUnit: time_unit,
                durationQuantity: quantity,
                isParkUntil: false,
                parkingAccountId: account_id
              }
            ).body
          end

          def new_ticket(token, account_id, quote_id, zipcode, license_plate, quantity, time_unit, start_time, payment_method_id:)
            base_data = {
              "expireTime": nil,
              "duration": {
                "quantity": quantity,
                "timeUnit": time_unit
              },
              "licensePlate": license_plate,
              "locationId": zipcode,
              "rateOptionId": '75101',
              "startTime": start_time,
              "quoteId": quote_id,
              "parkingAccountId": account_id
            }

            payment_data = {
              "paymentMethod": {
                "paymentMethodType": 'PaymentAccount',
                "payload": {
                  "paymentAccountId": payment_method_id,
                  "clientBrowserDetails": {
                    "browserAcceptHeader": 'text/html',
                    "browserColorDepth": '30',
                    "browserJavaEnabled": 'false',
                    "browserLanguage": 'fr-FR',
                    "browserScreenHeight": '900',
                    "browserScreenWidth": '1440',
                    "browserTimeZone": '-60',
                    "browserUserAgent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
                  }
                }
              }
            }

            final_data = payment_method_id ? base_data.merge(payment_data) : base_data

            connection(token).post(
              "/parking/accounts/#{account_id}/sessions/",
              final_data.to_json
            ).body
          end

          def payment_methods(token)
            connection(token).get('/payment/v3/accounts').body
          end

          private

          def connection(token)
            Faraday.new(
              url: 'https://consumer.paybyphoneapis.com',
              headers: {
                'Content-Type' => 'application/json',
                'Authorization' => "Bearer #{token}"
              }
            ) do |f|
              f.response :json
            end
          end
        end

        def initialize(username, password)
          @username = username
          @password = password
        end

        def vehicles
          self.class.vehicles(token)
        end

        def rate_options(zipcode, license_plate)
          self.class.rate_options(token, account_id, zipcode, license_plate)
        end

        def running_tickets
          self.class.running_tickets(token, account_id)
        end

        def payment_methods
          self.class.payment_methods(token)
        end

        def quote(rate_option_id, zipcode, license_plate, quantity, time_unit)
          self.class.quote(token, account_id, rate_option_id, zipcode, license_plate, quantity, time_unit)
        end

        def new_ticket(quote_id, zipcode, license_plate, quantity, time_unit, start_time, payment_method_id:)
          self.class.new_ticket(token, account_id, quote_id, zipcode, license_plate, quantity,
                                time_unit, start_time, payment_method_id)
        end

        private

        def token
          @token ||= self.class.auth(@username, @password).body['access_token']
        end

        def account_id
          @account_id ||= self.class.account_id(token)
        end
      end
    end
  end
end
