# Amqparty

An adaptation of HTTParty for use with rack-amqp-client

## Installation

Add this line to your application's Gemfile:

    gem 'amqparty'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install amqparty

## Usage

AMQParty.get("amqp://localhost/queue.name/users")

Uri scheme must be amqp or amqps. Hostname is the hostname of the
rabbitmq server. First segment of the path is actually the queue name.
Allows username/password in the host in the traditional
user:password@hostname format.

Post and put also work. Delete, head, options are untested.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
