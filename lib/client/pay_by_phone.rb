require 'faraday'
class PayByPhone
  def tickets
    connection.get("/parking/accounts/#{account_id}/sessions?periodType=Current").body
  end

  def account_id
    connection.get('/parking/accounts').body.dig(0, 'id')
  end

  def vehicles
    connection.get('/identity/profileservice/v1/members/vehicles/paybyphone').body
  end

  def rate_options
    connection.get('/parking/locations/75018/rateOptions',
                   {
                     parkingAccountId: account_id,
                     licensePlate: ENV['PAYBYPHONE_LICENSEPLATE']
                   }).body
  end

  def quote
    connection.get(
      "/parking/accounts/#{account_id}/quote",
      {
        locationId: ENV['PAYBYPHONE_ZIPCODE'],
        licensePlate: ENV['PAYBYPHONE_LICENSEPLATE'],
        stall: nil,
        rateOptionId: '75101',
        durationTimeUnit: 'Days',
        durationQuantity: 1,
        isParkUntil: false,
        expireTime: nil,
        parkingAccountId: account_id
      }
    ).body
  end

  def member_id
    connection.get('/identity/profileservice/v1/members').body['memberId']
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
