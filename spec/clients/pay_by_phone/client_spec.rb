module ParkingTicket::Clients::PayByPhone
  RSpec.describe Client do
    subject { described_class.new(username, password) }
    let(:username) { ENV['PARKING_TICKET_USERNAME'] }
    let(:password) { ENV['PARKING_TICKET_PASSWORD'] }
    let(:zipcode) { ENV['PARKING_TICKET_ZIPCODE'] }
    let(:license_plate) { ENV['PARKING_TICKET_LICENSEPLATE'] }
    describe '#instance_methods' do
      context '#vehicles' do
        it 'returns the vehicles' do
          expect(subject.vehicles).to match_json_schema('client/pay_by_phone/request/vehicles')
        end
      end
      context '#rate_options' do
        it 'returns the rate options for a zipcode, an account_id and a vehicle' do
          result = subject.rate_options(zipcode, license_plate)
          expect(result).to match_json_schema('client/pay_by_phone/request/rate_options')
          expect(result.length).to be > 1
        end
      end
      context '#running_tickets' do
        it 'returns the current tickets' do
          expect(subject.running_tickets).to match_json_schema('client/pay_by_phone/request/tickets')
        end
      end
      context '#payment_methods' do
        it 'returns the payment_methods registered for an account' do
          expect(subject.payment_methods).to match_json_schema('client/pay_by_phone/request/payment_methods')
        end
      end
      context '#quote' do
        let!(:rate_option_id) do
          subject.rate_options(zipcode, license_plate).find do |rate_option|
            rate_option['type'] == 'RES' && rate_option['licensePlate'] == license_plate
          end['rateOptionId']
        end

        it 'returns the rate options for a zipcode, an account_id and a vehicle' do
          expect(subject.quote(rate_option_id, zipcode, license_plate, 1,
                               'Days')).to match_json_schema('client/pay_by_phone/request/quote')
        end
      end
    end
    describe '.class_methods' do
      it 'fetches the PayByPhoneApi'
    end
  end
end
