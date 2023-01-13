module ParkingTicket
  module Client
    module PayByPhone
      class Configuration < ParkingTicket::Configuration
        attr_required :username, :password, :license_plate, :zipcode, :card_number
      end
    end
  end
end
