require 'ruble/ui'
require 'ruble/command'
require 'ruble/context'
require 'ruble/invoke'
require 'ruble/editor'


module Ruble
  
  class Logger
    class << self
      def log_error(error)
        puts "Error: #{error.to_s}"
      end
      
      def log_level
        @log_level.name.to_sym
      end
      
      def log_level=(level)
        @log_level = level.to_s
      end
      
      def log_info(info)
        puts "Info: #{info.to_s}"
      end
      
      def log_warning(warning)
        puts "Warning: #{warning.to_s}"
      end
      
      def trace(message)
        puts "Trace: #{message.to_s}"
      end
    end
  end
  
end

# define top-level convenience methods

def log_error(error)
  Ruble::Logger.log_error(error)
end

def log_info(info)
  Ruble::Logger.log_info(info)
end

def log_warning(warning)
  Ruble::Logger.log_warning(warning)
end

def trace(message)
  Ruble::Logger.trace(message)
end
