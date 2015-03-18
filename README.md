# Caerbannog
Implements a database buffer and workers for sending and receiving events to/from RabbitMQ.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'caerbannog'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install caerbannog

## Usage

The gem is ment to be used by a sender application and a receiver application.

### On the sender side
To send messages you call the `Caerbannog::Queue.push` method with a message name, that will be used
as the routing queue, and the message payload. But first you need to configure the `Caerbannog::Queue`
with a message class that responds to `create!` and `all`. This class will be used when you call
`Caerbannog::Queue.push` to store the message before sending it to RabbitMQ, and then by a background
publisher that uses the `all` method to fetch all pushed messages and send them to RabbitMQ.

If you are using this gem from within a Rails application you can run
```ruby
rails generate caerbannog
```
This generates a migration file, an ActiveRecord message model, and an initializer file.

To actually get the messages to RabbitMQ you need a publisher process that gets messages from the
configured message class and sends them to RabbitMQ. If you have initialized the
`Caerbannog::Queue#message_class`, you can use something like this

```ruby
bundle exec rails runner 'Caerbannog::Queue.publish'
```

### On the receiving side
To receive messages you need to run a subscriber process that calls the `Caerbannog::Queue.subscribe` method.
An example subscriber class might look like this.

```ruby
class CaerbannogSubscriber
  def perform
    begin
      Caerbannog::Queue.subscribe("my-apps-queue-name", 'message-name1', 'message-name2') do |delivery_info, properties, payload|
        parsed_message = JSON.parse(payload)
        # Do something with the parsed messaga
      end
    rescue Bunny::TCPConnectionFailedForAllHosts => e
      ExceptionService.handle(e, :message => "Can't connect to RabbitMQ")
      sleep 10        # Wait for RabbitMQ to come back up
      retry           # Try to reconnect
    end
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/caerbannog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
