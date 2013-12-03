require "active_support"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"
require "active_public_resources/version"
require "active_public_resources/client"
require "active_public_resources/request_criteria"

# Drivers
require "active_public_resources/driver"
require "active_public_resources/driver_response"
require "active_public_resources/drivers/vimeo"
require "active_public_resources/drivers/youtube"
require "active_public_resources/drivers/schooltube"
require "active_public_resources/drivers/khan_academy"
require "active_public_resources/drivers/quizlet"

# Return Types
require "active_public_resources/base_return_type"
require "active_public_resources/return_types/file"
require "active_public_resources/return_types/iframe"
require "active_public_resources/return_types/image_url"
require "active_public_resources/return_types/oembed"
require "active_public_resources/return_types/url"

# Response Types
require "active_public_resources/base_response_type"
require "active_public_resources/response_types/video"
require "active_public_resources/response_types/image"
require "active_public_resources/response_types/exercise"
require "active_public_resources/response_types/folder"
require "active_public_resources/response_types/quiz"

module ActivePublicResources
  def self.root
    File.expand_path '../..', __FILE__
  end

  def self.symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize_keys(value)
                  when Array then value.map{ |v| v.is_a?(Hash) ? symbolize_keys(v) : v }
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end
end

APR = ActivePublicResources
