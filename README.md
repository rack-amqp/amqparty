# Amqparty

A AMQP-HTTP compliant modification of HTTParty for use with jackalope

## Installation

Add this line to your application's Gemfile:

    gem 'amqparty'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install amqparty

## Usage

First configure AMQParty to connect to your AMQP broker (RabbitMQ or
other)

```ruby
AMQParty.configure do |c|
  c.amqp_host = 'localhost'
end
```

Then you can use it to talk to your service:

```ruby
AMQParty.get("amqp://queue.name/path")
```

Uri scheme must be amqp or amqps. Hostname is actually the queue name.

Post and put also work. Delete, head, options are untested.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
