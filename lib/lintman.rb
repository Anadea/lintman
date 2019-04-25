require 'lintman/version'
require 'lintman/railtie' if defined?(Rails)

module Lintman
  class Error < StandardError; end
  # Your code goes here...
end
