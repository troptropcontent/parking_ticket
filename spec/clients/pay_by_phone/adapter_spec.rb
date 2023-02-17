module ParkingTicket::Clients::PayByPhone
  RSpec.describe Adapter do
    let(:username) { 'fake_username' }
    let(:password) { 'fake_password' }
    let(:license_plate) { 'license_plate' }

    let(:zipcode) { '75018' }

    subject { described_class.new(username, password) }
    describe '#class_methods' do
      context '#vehicles', :vcr do
        it 'returns the list of the vehicles' do
          expect(subject.vehicles).to eq([{
                                           client_internal_id: 'fake_vehicle_id', license_plate: license_plate, type: 'Car'
                                         }])
        end
      end
      context '#rate_options' do
        it 'returns the list of the rate options available', :vcr do
          expect(subject.rate_options(zipcode, license_plate)).to include({
                                                                            client_internal_id: instance_of(String),
                                                                            name: instance_of(String),
                                                                            type: instance_of(String),
                                                                            accepted_time_units: instance_of(Array)
                                                                          })
        end
      end

      context '#running_ticket(license_plate, zipcode)' do
        it 'returns the running ticket', :vcr do
          expect(subject.rate_options(zipcode,
                                      license_plate)).to contain_exactly({ accepted_time_units: ['days'],
                                                                           client_internal_id: '75101',
                                                                           name: 'Résident',
                                                                           type: 'RES' },
                                                                         { accepted_time_units: %w[minutes hours],
                                                                           client_internal_id: '1085252721',
                                                                           name: 'Voiture - Visiteur - 75012-75020',
                                                                           type: 'CUSTOM' })
        end
      end

      context '#payment_methods' do
        it 'returns the payment method registered for the account', :vcr do
          expect(subject.payment_methods).to contain_exactly({ anonymised_card_number: '2021',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'master_card' },
                                                             { anonymised_card_number: '2358',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'visa' },
                                                             { anonymised_card_number: '4436',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'visa' },
                                                             { anonymised_card_number: '9321',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'master_card' },
                                                             { anonymised_card_number: '6750',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'master_card' },
                                                             { anonymised_card_number: '6156',
                                                               client_internal_id: 'fake_payment_method_id',
                                                               payment_card_type: 'visa' })
        end
      end

      context '#new_ticket(license_plate, zipcode, rate_option_id, quantity, time_unit, payment_method_id)' do
        let(:rate_option_id) { 'a_fake_rate_option_id' }
        let(:payment_method_id) { 'a_fake_rate_option_id' }
        it 'request a new ticket', :vcr do
          client_double = instance_double(
            ParkingTicket::Clients::PayByPhone::Client,
            running_tickets: {},
            payment_methods: { 'items' => [{ 'id' => 'fake_payment_method_id', 'maskedCardNumber' => '2021',
                                             'paymentCardType' => 'Days' }] },
            quote: { 'quoteId' => 'faked_quote_id', 'parkingStartTime' => 'fake_start_date',
                     'parkingExpiryTime' => 'fake_expiry_time' }
          )
          allow(ParkingTicket::Clients::PayByPhone::Client).to receive(:new).and_return(client_double)
          expect(client_double).to receive(:new_ticket).with(
            'faked_quote_id',
            'fake_payment_method_id',
            '75018',
            'license_plate',
            1,
            'Days',
            'fake_start_date'
          )
          subject.new_ticket('license_plate', '75018', '75001', 1, 'days', 'fake_payment_method_id')
        end
      end
    end
  end
end
