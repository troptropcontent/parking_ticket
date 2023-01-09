require 'faraday'
class PayByPhone
  def tickets(account_id)
    connection.get("/parking/accounts/#{account_id}/sessions?periodType=Current").body
  end

  def new_ticket(account_id, parking_start_time, quote_id, payment_method_id)
    connection.post(
      "/parking/accounts/#{account_id}/sessions/",
      {
        "expireTime": nil,
        "duration": {
          "quantity": '1',
          "timeUnit": 'days'
        },
        "licensePlate": ENV['PAYBYPHONE_LICENSEPLATE'],
        "locationId": ENV['PAYBYPHONE_ZIPCODE'],
        "rateOptionId": '75101',
        "startTime": parking_start_time,
        "quoteId": quote_id,
        "parkingAccountId": account_id,
        "paymentMethod": {
          "paymentMethodType": 'PaymentAccount',
          "payload": {
            "paymentAccountId": payment_method_id,
            "clientBrowserDetails": {
              "browserAcceptHeader": 'text/html',
              "browserColorDepth": '30',
              "browserJavaEnabled": 'false',
              "browserLanguage": 'fr-FR',
              "browserScreenHeight": '900',
              "browserScreenWidth": '1440',
              "browserTimeZone": '-60',
              "browserUserAgent": 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36'
            }
          }
        }
      }
    ).body
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
