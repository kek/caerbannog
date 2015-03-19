# Caerbannog
[![Circle CI](https://circleci.com/gh/magplus/caerbannog.png?style=shield)](https://circleci.com/gh/magplus/caerbannog)

Implements a database buffer and workers for sending and receiving events
to/from RabbitMQ.


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

The gem is meant to be used by a sender application and one or more receiver
applications. The RabbitMQ instance used is configured via the RABBIT_URL environment variable.

### On the sender side

`Caerbannog::Queue` needs to be configured with a message storage class that is an
ActiveRecord model or works like an ActiveRecord model with regards to the
methods `.all`, `.create!` and `#destroy`, and has two attributes `name` and
`payload`.

```ruby
Caerbannog::Queue.message_class = MessageQueueMessage
```

If you are using the gem from within a Rails application, you can run the
following to generate this model:

    $ rails generate caerbannog

This generates a migration file, an ActiveRecord message class
`MessageQueueMessage`, and an initializer file.

This class will be used to store messages when you call
`Caerbannog::Queue.push`, before they are sent to RabbitMQ,

Call the `Caerbannog::Queue.push` method with two parameters: the message name,
that will be used as the routing key in RabbitMQ, and the message payload,
which should be a hash or an array.

```ruby
Caerbannog::Queue.push('message name', { one_field: 'one', two_field: 'two' })
```

We then need a background publisher that uses the `all` method of the message
class to fetch all pushed messages and send them to RabbitMQ, and then
`destroy`s them.

If you have initialized the `Caerbannog::Queue#message_class=`, you can use
something like this to start the publisher process:

    $ bundle exec rails runner 'Caerbannog::Queue.publish'

### On the receiving side

To receive messages you need to run a subscriber process that calls the
`Caerbannog::Queue.subscribe` method.  An example subscriber class with some
error handling might look like this:

```ruby
class MessageQueueWorker
  def perform
    Caerbannog::Queue.subscribe('my-apps-queue-name', 'message-name1', 'message-name2') do |delivery_info, properties, payload|
      parsed_message = JSON.parse(payload)
      # Do something with the parsed message
    end
  rescue Bunny::TCPConnectionFailedForAllHosts => e
    puts 'Oh no' # Handle the error somehow
    sleep 10 # Wait for RabbitMQ to come back up
    retry # Try to reconnect
  end
end
```

and you might run this process like

    $ bundle exec rails runner 'MessageQueueWorker'

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release` to create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/caerbannog/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
