module ApplicationHelper

  module JSON
    def self.is_json?(json)
      begin
        return false unless json.is_a?(String)
        JSON.parse(json).all?
      rescue JSON::ParserError
        false
      end
    end
  end

end
