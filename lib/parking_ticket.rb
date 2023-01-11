# frozen_string_literal: true

require 'parking_ticket/configuration'
require 'parking_ticket/version'
require 'client/pay_by_phone'
require 'client/pay_by_phone/adapter'

module ParkingTicket
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.configured?
    self&.adapter&.ready?
  end

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
    configuration.adapter
  end
end
