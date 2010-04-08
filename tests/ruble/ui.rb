module Ruble
  class UI
    # Allows tests to queue up strings to return
    def self.add_string_for_request(string)
      @@strings ||= []
      @@strings << string
    end
    
    def self.request_string(hash = {})
      @@strings ||= []
      @@strings.shift
    end
    
    def self.request_secure_string(hash = {})
      request_string(hash)
    end
  end
end