# Workflow Experiment

This is a loose experiment about a pattern for implementing a flexible workflow (or process
object, or service or whatever) pattern with asynchronous queueing backed by Resque. The goal is
an interface where workflows can be executed immediately or asynchronously without directly
exposing the plumbing of the job queue.

Workflows are instance based instead of the less flexible class based design of Resque. This
makes testing easier and also encourages good practices like extracting methods, etc.

```ruby
class Greeting < Workflow
  def initialize(name)
    @name = name
  end

  def run
    puts "Hello, #{@name}!"
  end
end

Greeting.run('Alice') #=> Immediately "Hello, Alice!"
Greeting.run_later('Bob') #=> Later... "Hello, Bob!"
```
