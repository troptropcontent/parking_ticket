# frozen_string_literal: true

module ParkingTicket
  RSpec.describe Base do
    subject do
      described_class.new(
        adapter_name,
        configuration_attributes
      )
    end
    let(:adapter_name) { nil }
    let(:configuration_attributes) { nil }
    it 'has a version number' do
      expect(ParkingTicket::VERSION).not_to be nil
    end

    describe '#instance_methods' do
      describe '#current_ticket' do
        context 'when it is pay_by_phone' do
          let(:adapter_name) { 'pay_by_phone' }
          let(:configuration_attributes) do
            {
              username: ENV['PARKING_TICKET_USERNAME'],
              password: ENV['PARKING_TICKET_PASSWORD'],
              license_plate: ENV['PARKING_TICKET_LICENSEPLATE'],
              zipcode: ENV['PARKING_TICKET_ZIPCODE'],
              card_number: ENV['PARKING_TICKET_CARDNUMBER']
            }
          end
          it 'uses the pay_by_phone adapter' do
            pay_by_phone_adapter_double = instance_double(ParkingTicket::Client::PayByPhone::Adapter)
            allow(ParkingTicket::Client::PayByPhone::Adapter).to receive(:new).and_return(pay_by_phone_adapter_double)
            expect(pay_by_phone_adapter_double).to receive(:current_ticket)
            subject.current_ticket
          end

          describe 'errors' do
            context 'when the configuration is not complete' do
              let(:configuration_attributes) do
                {
                  username: ENV['PARKING_TICKET_USERNAME'],
                  password: ENV['PARKING_TICKET_PASSWORD'],
                  license_plate: ENV['PARKING_TICKET_LICENSEPLATE'],
                  zipcode: ENV['PARKING_TICKET_ZIPCODE']
                }
              end
              it 'raises a Uncompleted configuration error' do
                expect do
                  subject.current_ticket
                end.to raise_error(ParkingTicket::Base::Error, 'Uncompleted configuration')
              end
            end
          end
        end
        context 'when the adapter is easy_park' do
          let(:adapter_name) { 'easy_park' }
          it 'raises a EasyPark will be handled in the next major release error' do
            expect do
              subject.current_ticket
            end.to raise_error(ParkingTicket::Base::Error, 'EasyPark will be handled in the next major release')
          end
        end
        context 'when the adapter is something else' do
          let(:adapter_name) { 'something_else' }
          it 'raises a Unhandled adapter error' do
            expect do
              subject.current_ticket
            end.to raise_error(ParkingTicket::Base::Error, 'Unhandled adapter : something_else')
          end
        end
      end
      describe '#renew' do
        context 'when it is pay_by_phone' do
          let(:adapter_name) { 'pay_by_phone' }
          let(:configuration_attributes) do
            {
              username: ENV['PARKING_TICKET_USERNAME'],
              password: ENV['PARKING_TICKET_PASSWORD'],
              license_plate: ENV['PARKING_TICKET_LICENSEPLATE'],
              zipcode: ENV['PARKING_TICKET_ZIPCODE'],
              card_number: ENV['PARKING_TICKET_CARDNUMBER']
            }
          end
          context 'when there is no current_ticket' do
            it 'uses the pay_by_phone adapter to renew a ticket' do
              pay_by_phone_adapter_double = instance_double(
                ParkingTicket::Client::PayByPhone::Adapter,
                current_ticket: nil
              )
              allow(ParkingTicket::Client::PayByPhone::Adapter).to receive(:new).and_return(pay_by_phone_adapter_double)
              expect(pay_by_phone_adapter_double).to receive(:renew)
              subject.renew
            end
          end
          context 'when there is a current_ticket' do
            it 'uses the pay_by_phone adapter to renew a ticket' do
              pay_by_phone_adapter_double = instance_double(
                ParkingTicket::Client::PayByPhone::Adapter,
                current_ticket: {}
              )
              allow(ParkingTicket::Client::PayByPhone::Adapter).to receive(:new).and_return(pay_by_phone_adapter_double)
              expect(pay_by_phone_adapter_double).not_to receive(:renew)
              subject.renew
            end
          end

          describe 'errors' do
            context 'when the configuration is not complete' do
              let(:configuration_attributes) do
                {
                  username: ENV['PARKING_TICKET_USERNAME'],
                  password: ENV['PARKING_TICKET_PASSWORD'],
                  license_plate: ENV['PARKING_TICKET_LICENSEPLATE'],
                  zipcode: ENV['PARKING_TICKET_ZIPCODE']
                }
              end
              it 'raises a Uncompleted configuration error' do
                expect do
                  subject.renew
                end.to raise_error(ParkingTicket::Base::Error, 'Uncompleted configuration')
              end
            end
          end
        end
        context 'when the adapter is easy_park' do
          let(:adapter_name) { 'easy_park' }
          it 'raises a EasyPark will be handled in the next major release error' do
            expect do
              subject.current_ticket
            end.to raise_error(ParkingTicket::Base::Error, 'EasyPark will be handled in the next major release')
          end
        end
        context 'when the adapter is something else' do
          let(:adapter_name) { 'something_else' }
          it 'raises a Unhandled adapter error' do
            expect do
              subject.current_ticket
            end.to raise_error(ParkingTicket::Base::Error, 'Unhandled adapter : something_else')
          end
        end
      end
    end
  end
end
