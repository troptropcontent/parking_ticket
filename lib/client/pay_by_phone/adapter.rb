require_relative '../pay_by_phone'
class PayByPhone::Adapter
  def covered?
    !!current_ticket
  end

  def renew
    return if covered?

    quote = client.new_quote
    puts client.new_ticket(account_id, quote['parkingStartTime'], quote['quoteId'], payment_method_id)
  end

  private

  def client
    @client ||= PayByPhone.new
  end

  def account_id
    @account_id ||= client.accounts.dig(0, 'id')
  end

  def new_quote
    client.quote(rate_option_id, account_id)
  end

  def payment_method_id
    client.payment_methods['items'].find do |payment_method|
      payment_method['maskedCardNumber'] == ENV['PAYBYPHONE_CARDNUMBER']
    end['id']
  end

  def rate_option_id
    client.rate_options(account_id).find do |rate_option|
      rate_option['type'] == 'RES' && rate_option['licensePlate'] == ENV['PAYBYPHONE_LICENSEPLATE']
    end['rateOptionId']
  end

  def current_ticket
    client.tickets(account_id).find do |ticket|
      ticket.dig('vehicle', 'licensePlate') == ENV['PAYBYPHONE_LICENSEPLATE']
    end
  end
end
