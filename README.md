# Amqparty

A AMQP-HTTP compliant modification of HTTParty for use with jackalope

![Travis CI](https://travis-ci.org/rack-amqp/amqparty.svg?branch=master)

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

Valid configuration parameters are shown below:

| Parameters            |                               Description                              | Default Value |
|-----------------------|:----------------------------------------------------------------------:|--------------:|
| amqp\_host            |             host name or IP address of the rabbitmq server             |     localhost |
| port                  |                          rabbitmq server port                          |          5672 |
| username              |           username to use for the rabbitmq server connection           |         guest |
| password              |           password to use for the rabbitmq server connection           |         guest |
| tls                   |             use TLS when connecting to the rabbitmq server             |         false |
| tls\_ca\_certificates |           an array of paths to CA certificates in pem format           |            [] |
| tls\_cert             |    path to the client certificate for SSL connections in PEM format    |           nil |
| tls\_key              |    path to the client private key for SSL connections in PEM format    |           nil |
| verify\_peer          |            disable/enable peer verification (used with TLS)            |         false |
| request\_timeout      | value in seconds indicating the reply wait timeout for an amqp request |             5 |

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
