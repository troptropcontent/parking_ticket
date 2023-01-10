# ParkingTicket

This gem is a wrapper around the majors residential parking tickets api (for now only PayByPhone is supported).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'parking_ticket'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install parking_ticket

## Usage

To make the gem work above your parking account you need set some environment variables : 

#PayByPhone : 
- `PAYBYPHONE_PASSWORD` : your PayByPhone password
- `PAYBYPHONE_USERNAME` : your PayByPhone username (usually your phone number)
- `PAYBYPHONE_LICENSEPLATE` : tyhe license plate of the car that must be covered 
- `PAYBYPHONE_ZIPCODE` : the zipcode you're resident in 
- `PAYBYPHONE_CARDNUMBER` : the credit card used to pay parking tickets (must be formated as folow xxxxxx------xxxx)

#Other apis to come

Two methods comes with the gem : 

#`ParkingTicket.current_ticket`
=> returns an object representing a currently running residential ticket for your car. It returns nil if no ticket are found.

#`ParkingTicket.renew`
=> register a new residential ticket for your car, this won't work if current_ticket returns something.

Then you can create a scrypt like this one :

```
#your_scrypt.rb
require 'parking_ticket'

ticket_client = ParkingTicket.new

unless ticket_client.current_ticket
  ticket_client.renew
end

```

And play as often as you want to ensure that you always have a ticket for your car.
(But this is very HTTP request consuming, a lot of wasted request will be performed, i am sure that you can do better than that.)


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
