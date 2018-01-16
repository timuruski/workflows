require 'bundler/setup'
require 'resque'

class Workflow
  MAX_RETRIES = 3

  def self.run(*args)
    new(*args).run
  end

  def self.run_later(*args)
    metadata = {'retries' => MAX_RETRIES}
    Resque.enqueue(self, metadata, args)
  end

  # Resque interface
  def self.perform(metadata, args)
    run(*args)
  rescue => error
    if metadata['retries'] > 0
      warn "#{error.class}: #{error.message}"
      metadata = metadata.merge('retries' => metadata['retries'] - 1)
      Resque.enqueue(self, metadata, args)
    else
      raise error
    end
  end

  def self.queue=(queue)
    @queue = queue
  end

  def self.queue
    @queue ||= 'default'
  end
end

class MakeSandwich < Workflow
  INGREDIENTS = [
    'chicken salad',
    'egg salad',
    'ham and cheese',
    'italian deli',
    'tunafish',
  ]

  self.queue = 'sandwiches'

  def initialize(ingredients, order)
    @ingredients = ingredients
    @order = order
  end

  def run
    puts "Making #{@ingredients} sandwich, order #{@order}..."
    # sleep 0.1
    raise "Oops, dropped order #{@order} on the floor!" if rand < 0.1
  end

end

if $0 == __FILE__
  10.times do |order|
    ingredients = MakeSandwich::INGREDIENTS.sample
    MakeSandwich.run_later(ingredients, order)
  end
end
