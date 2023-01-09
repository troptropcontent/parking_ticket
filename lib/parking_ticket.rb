# frozen_string_literal: true

require_relative 'parking_ticket/version'
require_relative 'client/pay_by_phone'
require_relative 'client/pay_by_phone/adapter'

module ParkingTicket
  class Error < StandardError; end

  def self.renew
    if current_ticket
      puts '❌ Can not renew ticket as already covered by a ticket at this time'
    else
      puts '🔄 Renewing ticket'
      adapter.renew
      puts '✅ Ticket renewed'
    end
  end

  def self.current_ticket
    puts '🕵️ Retrieving current_ticket'
    adapter.current_ticket
  end

  def self.adapter
    @@adapter ||= PayByPhone::Adapter.new
  end
end
