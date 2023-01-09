require 'spec_helper'

RSpec.describe PayByPhone, type: :model do
  describe '#instance_methods' do
    context '#accounts' do
      it 'returns the accounts' do
        expect(subject.accounts).to match_json_schema('client/pay_by_phone/accounts')
      end
    end
    context '#tickets' do
      let!(:account_id) do
        subject.accounts.dig(0, 'id')
      end
      it 'returns the current tickets' do
        expect(subject.tickets(account_id)).to match_json_schema('client/pay_by_phone/tickets')
      end
    end
    context '#vehicles' do
      it 'returns the vehicles' do
        expect(subject.vehicles).to match_json_schema('client/pay_by_phone/vehicles')
      end
    end
    context '#rate_options' do
      let!(:account_id) do
        subject.accounts.dig(0, 'id')
      end
      it 'returns the rate options for a zipcode, an account_id and a vehicle' do
        expect(subject.rate_options(account_id)).to match_json_schema('client/pay_by_phone/rate_options')
      end
    end
    context '#quote' do
      let!(:account_id) do
        subject.accounts.dig(0, 'id')
      end
      let!(:rate_option_id) do
        subject.rate_options(account_id).find do |rate_option|
          rate_option['type'] == 'RES' && rate_option['licensePlate'] == ENV['PAYBYPHONE_LICENSEPLATE']
        end['rateOptionId']
      end
      it 'returns the rate options for a zipcode, an account_id and a vehicle' do
        expect(subject.quote(rate_option_id, account_id)).to match_json_schema('client/pay_by_phone/quote')
      end
    end
    context '#member' do
      it 'returns the rate options for a zipcode, an account_id and a vehicle' do
        expect(subject.member).to match_json_schema('client/pay_by_phone/member')
      end
    end
  end
end
