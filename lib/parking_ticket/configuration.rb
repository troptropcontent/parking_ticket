module ParkingTicket
  class Configuration
    attr_reader :adapter
    attr_accessor :username, :password, :license_plate, :zipcode, :card_number

    def initialize
      @adapter = nil
      @username = nil
      @password = nil
      @license_plate = nil
      @zipcode = nil
      @card_number = nil
    end

    def adapter=(adapter_name)
      case adapter_name
      when 'pay_by_phone'
        @adapter = PayByPhone::Adapter
      when 'easy_park'
        raise Error, "Adapter easy_park will be available in the next major realease : #{adapter_name}"
      else
        raise Error, "Unhandled adapter : #{adapter_name}"
      end
    end
  end
end
