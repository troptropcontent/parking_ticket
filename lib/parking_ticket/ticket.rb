class ParkingTicket::Ticket
  def initialize(attributes)
    @starts_on = attributes[:starts_on]
    @ends_on = attributes[:ends_on]
    @license_plate = attributes[:license_plate]
    @cost = attributes[:cost]
    @client = attributes[:client]
    @client_ticket_id = attributes[:client_ticket_id]
  end

  def to_h
    {
      starts_on: @starts_on,
      ends_on: @ends_on,
      license_plate: @license_plate,
      cost: @cost,
      client: @client,
      client_ticket_id: @client_ticket_id
    }
  end
end
