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

# class MakeSandwich
#   @queue = 'default'

#   def self.perform(args)
#     new(**args.transform_keys(&:to_sym)).perform
#   end

#   # ---

#   INGREDIENTS = [
#     'chicken salad',
#     'egg salad',
#     'ham and cheese',
#     'italian deli',
#     'tunafish',
#   ]

#   def self.random_ingredients(order:)
#     Resque.enqueue(self, order: order, ingredients: INGREDIENTS.sample)
#   end

#   def initialize(order:, ingredients:)
#     @order = order
#     @ingredients = ingredients
#   end

#   def perform
#     # puts "Making #{@ingredients} sandwich..."
#     sleep 0.1
#     raise "Oops, dropped sandwich on the floor..." if rand < 0.1
#     puts "Order #{@order} up!"
#   rescue
#     Resque.enqueue(self.class, order: @order, ingredients: @ingredients)
#   end
# end

if $0 == __FILE__
  50.times do |order|
    ingredients = Workflows::MakeSandwich::INGREDIENTS.sample
    Workflows::MakeSandwich.run_later(ingredients, order)
  end
end
