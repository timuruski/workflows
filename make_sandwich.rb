require 'bundler/setup'
require 'resque'

module Workflows
  class MakeSandwich
  INGREDIENTS = [
    'chicken salad',
    'egg salad',
    'ham and cheese',
    'italian deli',
    'tunafish',
  ]

    def initialize(ingredients, order)
      @ingredients = ingredients
      @order = order
    end

    def run
      puts "Making #{@ingredients} sandwich, order #{@order}..."
      # sleep 0.1
      raise "Oops, dropped order #{@order} on the floor..." if rand < 0.1
    end

    # Workflow interface
    def self.run(*args)
      new(*args).run
    end

    def self.run_later(*args)
      Resque.enqueue(self, *args)
    end

    # Resque interface
    @queue = 'default'

    def self.perform(*args)
      run(*args)
    rescue => error
      warn error.message
      Resque.enqueue(self, *args)
    end
  end
end

if $0 == __FILE__
  50.times do |order|
    ingredients = Workflows::MakeSandwich::INGREDIENTS.sample
    Workflows::MakeSandwich.run_later(ingredients, order)
  end
end
