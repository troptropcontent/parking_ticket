module ParkingTicket::Client::PayByPhone
  RSpec.describe Configuration do
    subject { described_class.new {} }
    describe 'attr_required' do
      RSpec.shared_examples 'has a setter and getter methods' do |attribute|
        it "has a #{attribute} getter and setter methods" do
          subject.send("#{attribute}=", 'toto')
          expect(subject.send(attribute)).to eq('toto')
        end
      end

      it_behaves_like 'has a setter and getter methods', 'username'
      it_behaves_like 'has a setter and getter methods', 'password'
      it_behaves_like 'has a setter and getter methods', 'license_plate'
      it_behaves_like 'has a setter and getter methods', 'zipcode'
      it_behaves_like 'has a setter and getter methods', 'card_number'
      context 'with a not required attribute' do
        it 'raises an undefined method' do
          expect do
            subject.toto
          end.to raise_error(NoMethodError,
                             /undefined method `toto' for #<ParkingTicket::Client::PayByPhone::Configuration/)
        end
      end
    end

    describe 'instance_methods' do
      context '#completed?' do
        context 'when all attr_required are filled in' do
          it 'return true' do
            subject.username = 'toto'
            subject.password = 'toto'
            subject.license_plate = 'toto'
            subject.zipcode = 'toto'
            subject.card_number = 'toto'

            expect(subject).to be_completed
          end
        end
        context 'when not all attr_required are filled in' do
          it 'return false' do
            subject.username = 'toto'
            subject.password = 'toto'
            subject.license_plate = 'toto'
            subject.zipcode = 'toto'

            expect(subject.completed?).to be false
          end
        end
      end
    end
  end
end
