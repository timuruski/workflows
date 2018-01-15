require 'bundler/setup'
require 'resque'
require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque/tasks'

module Resque::Failure
  class Stdout < Base
    BUNDLE_PATH = Bundler.bundle_path.to_s
    APP_PATH = __dir__ + '/'

    def save
      warn exception.message
      warn filter(exception.backtrace)
    end

    private

    def filter(backtrace)
      backtrace
        .select { |line| line.start_with?(APP_PATH) }
        .reject { |line| line.start_with?(BUNDLE_PATH) }
        .map { |line| line.delete_prefix(APP_PATH) }
    end
  end
end

namespace :resque do
  task :setup do
    Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Stdout]
    Resque::Failure.backend = Resque::Failure::Multiple
    Resque.logger.level = Logger::DEBUG

    require_relative 'make_sandwich'
  end
end
