module ParkingTicket::Client::PayByPhone
  RSpec.describe Adapter do
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
      context '#current_ticket' do
        context 'when a relevant ticket is returned' do
          let(:starts_on) { DateTime.now - 2 * 3600 }
          let(:ends_on) { DateTime.now + 2 * 3600 }
          let(:mocked_response) do
            [
              {
                'startTime' => (starts_on).strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                'expireTime' => (ends_on).strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                'vehicle' => { 'licensePlate' => config.license_plate },
                'segments' => [{ 'cost' => 1.5 }],
                'parkingSessionId' => 'a_fake_id'
              }
            ]
          end
          let(:expected_return) do
            {
              starts_on: starts_on,
              ends_on: ends_on,
              license_plate: config.license_plate,
              cost: 1.5,
              client: 'PayByPhone',
              client_ticket_id: 'a_fake_id'
            }
          end
          it 'return the current ticket' do
            request_double = instance_double(
              Request,
              tickets: mocked_response,
              accounts: [{ 'id' => 'a_fake_account_id' }]
            )
            allow(Request).to receive(:new).and_return(request_double)
            result = subject.current_ticket
            expect(result).to include(expected_return)
            expect(result.keys).to contain_exactly(*expected_return.keys)
          end
        end
        context 'when no relevant ticket is returned' do
          let(:starts_on) { DateTime.now - 2 * 3600 }
          let(:ends_on) { DateTime.now + 2 * 3600 }
          let(:mocked_response) do
            [
              {
                'startTime' => (starts_on).strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                'expireTime' => (ends_on).strftime('%Y-%m-%dT%H:%M:%S.%L%z'),
                'vehicle' => { 'licensePlate' => 'a not relevant license plate' },
                'segments' => [{ 'cost' => 1.5 }],
                'parkingSessionId' => 'a_fake_id'
              }
            ]
          end
          it 'returns nil' do
            request_double = instance_double(
              Request,
              tickets: mocked_response,
              accounts: [{ 'id' => 'a_fake_account_id' }]
            )
            allow(Request).to receive(:new).and_return(request_double)
            expect(subject.current_ticket).to eq(nil)
          end
        end
        context 'when no tickets are returned' do
          let(:starts_on) { DateTime.now - 2 * 3600 }
          let(:ends_on) { DateTime.now + 2 * 3600 }
          let(:mocked_response) do
            []
          end
          it 'returns nil' do
            request_double = instance_double(
              Request,
              tickets: mocked_response,
              accounts: [{ 'id' => 'a_fake_account_id' }]
            )
            allow(Request).to receive(:new).and_return(request_double)
            expect(subject.current_ticket).to eq(nil)
          end
        end
      end
      context '#renew' do
        context 'when there is current ticket' do
          it 'description' do
            allow(subject).to receive(:current_ticket).and_return([{}])
            expect(subject).not_to receive(:new_ticket)
            subject.renew
          end
        end
        context 'when there is no current ticket' do
          it 'description' do
            request_double = instance_double(
              Request,
              rate_options: [{ 'type' => 'RES', 'licensePlate' => config.license_plate }],
              accounts: [{ 'id' => 'test' }],
              new_quote: {},
              payment_methods: { 'items' => [{ 'maskedCardNumber' => config.card_number }] }
            )
            allow(Request).to receive(:new).and_return(request_double)
            allow(subject).to receive(:current_ticket).and_return(nil)
            expect(request_double).to receive(:new_ticket)
            subject.renew
          end
        end
      end
    end
  end
end
