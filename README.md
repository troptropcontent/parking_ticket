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

This give you access to a bunch of classes but the most important one is the ParkingTicket::Base. 

This class can be instanciated as follow : 

```
parking_ticket = ParkingTicket::Base.new(
  'pay_by_phone',
  {
    username: your_pay_by_phone_username,
    password: your_pay_by_phone_password,
    license_plate: your_license_plate,
    zipcode: the_zipcode_where_you_are_resident,
    card_number: the_card_number_registered_on_pay_by_phone_you_want_to_use, # must be in the format : xxxxxx------xxxx
  }
)
```

Once instanciated and configured correctly (the methods won't work if the is a missing key in the confguration hash), you can use the two instance methods to do what you have to do : 

- #current_ticket
This checks if a ticket is currently running for the license_plate. 
Returns :
```
#if a ticket is found : 
{
  starts_on: 2023-01-11 15:40:22 UTC,
  ends_on: 2023-01-18 15:40:22 UTC,
  cost: 9.0,
  license_plate: your_license_plate,
  client: "PayByPhone",
  client_ticket_id: the_id_returned_by_the_adapter,
}

#if no ticket is found
nil
```

- #renew
This will trigger the renewal of your ticket, works only if no current_ticket is found

Then you can create a scrypt like this one :

```
#your_scrypt.rb
require 'parking_ticket'

ticket_client = ParkingTicket::Base.new(
  'pay_by_phone',
  {
    username: your_pay_by_phone_username,
    password: your_pay_by_phone_password,
    license_plate: your_license_plate,
    zipcode: the_zipcode_where_you_are_resident,
    card_number: the_card_number_registered_on_pay_by_phone_you_want_to_use, # must be in the format : xxxxxx------xxxx
  }
)

unless ticket_client.current_ticket
  ticket_client.renew
end

```

And play it as often as you want to ensure that you always have a ticket for your car.
(But this is very HTTP request consuming, a lot of wasted request will be performed, i am sure that you can do better than that.)

Exemple of application : [parkautomat](https://github.com/troptropcontent/parkautomat)


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
