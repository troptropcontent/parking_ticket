module ParkingTicket::Client::PayByPhone
  RSpec.describe Request do
    let!(:config) do
      ParkingTicket::Client::PayByPhone::Configuration.new do |configuration|
        configuration.username = ENV['PARKING_TICKET_USERNAME']
        configuration.password = ENV['PARKING_TICKET_PASSWORD']
        configuration.zipcode = ENV['PARKING_TICKET_ZIPCODE']
        configuration.card_number = ENV['PARKING_TICKET_CARDNUMBER']
        configuration.license_plate = ENV['PARKING_TICKET_LICENSEPLATE']
      end
    end
    subject { described_class.new(config) }
    describe '#class_methods' do
      context '#accounts' do
        it 'returns the accounts' do
          expect(subject.accounts).to match_json_schema('client/pay_by_phone/request/accounts')
        end
      end
      context '#tickets' do
        let!(:account_id) do
          subject.accounts.dig(0, 'id')
        end
        it 'returns the current tickets' do
          expect(subject.tickets(account_id)).to match_json_schema('client/pay_by_phone/request/tickets')
        end
      end
      context '#vehicles' do
        it 'returns the vehicles' do
          expect(subject.vehicles).to match_json_schema('client/pay_by_phone/request/vehicles')
        end
      end
      context '#rate_options' do
        let!(:account_id) do
          subject.accounts.dig(0, 'id')
        end
        it 'returns the rate options for a zipcode, an account_id and a vehicle' do
          result = subject.rate_options(account_id)
          expect(result).to match_json_schema('client/pay_by_phone/request/rate_options')
          expect(result.length).to be > 1
        end
      end
      context '#quote' do
        let!(:account_id) do
          subject.accounts.dig(0, 'id')
        end
        let!(:rate_option_id) do
          subject.rate_options(account_id).find do |rate_option|
            rate_option['type'] == 'RES' && rate_option['licensePlate'] == config.license_plate
          end['rateOptionId']
        end
        it 'returns the rate options for a zipcode, an account_id and a vehicle' do
          expect(subject.new_quote(rate_option_id,
                                   account_id)).to match_json_schema('client/pay_by_phone/request/quote')
        end
      end
      context '#member' do
        it 'returns the rate options for a zipcode, an account_id and a vehicle' do
          expect(subject.member).to match_json_schema('client/pay_by_phone/request/member')
        end
      end
      context '#payment_methods' do
        it 'returns the payment_methods registered for an account' do
          expect(subject.payment_methods).to match_json_schema('client/pay_by_phone/request/payment_methods')
        end
      end
    end
  end
end
