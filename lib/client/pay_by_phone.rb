require 'faraday'
class PayByPhone
  def tickets(account_id)
    connection.get("/parking/accounts/#{account_id}/sessions?periodType=Current").body
  end

  def accounts
    connection.get('/parking/accounts').body
  end

  def vehicles
    connection.get('/identity/profileservice/v1/members/vehicles/paybyphone').body
  end

  def rate_options(account_id)
    connection.get("/parking/locations/#{ENV['PAYBYPHONE_ZIPCODE']}/rateOptions",
                   {
                     parkingAccountId: account_id,
                     licensePlate: ENV['PAYBYPHONE_LICENSEPLATE']
                   }).body
  end

  def quote(rate_option_id, account_id)
    connection.get(
      "/parking/accounts/#{account_id}/quote",
      {
        locationId: ENV['PAYBYPHONE_ZIPCODE'],
        licensePlate: ENV['PAYBYPHONE_LICENSEPLATE'],
        rateOptionId: rate_option_id,
        durationTimeUnit: 'Days',
        durationQuantity: 1,
        isParkUntil: false,
        parkingAccountId: account_id
      }
    ).body
  end

  def member
    connection.get('/identity/profileservice/v1/members').body
  end

  def payment_methods
    connection.get('/payment/v3/accounts').body
  end

  private

  def connection
    @connection ||= Faraday.new(
      url: 'https://consumer.paybyphoneapis.com',
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{token}"
      }
    ) do |f|
      f.response :json
    end
  end

  def token
    conn = Faraday.new('https://auth.paybyphoneapis.com') do |f|
      f.response :json
    end
    conn.post(
      '/token',
      URI.encode_www_form({
                            grant_type: 'password',
                            username: ENV['PAYBYPHONE_USERNAME'],
                            password: ENV['PAYBYPHONE_PASSWORD'],
                            client_id: 'paybyphone_web'
                          }),
      {
        'Accept' => 'application/json, text/plain, */*',
        'X-Pbp-ClientType' => 'WebApp'
      }
    ).body['access_token']
  end
end
