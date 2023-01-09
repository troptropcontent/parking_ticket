# frozen_string_literal: true

require_relative 'parking_ticket/version'
require_relative 'client/pay_by_phone'
require_relative 'client/pay_by_phone/adapter'

module ParkingTicket
  class Error < StandardError; end

  def self.renew
    if covered
      puts '❌ Can not renew ticket as already covered'
    else
      puts '🔄 Renewing ticket'
      adapter.renew
      puts '✅ Ticket renewed'
    end
  end

  def self.covered
    puts '🕵️ Checking coverage'
    adapter.covered?
  end

  def self.adapter
    @@adapter ||= PayByPhone::Adapter.new
  end
end
