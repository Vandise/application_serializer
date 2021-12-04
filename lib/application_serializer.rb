require "active_model_serializers"
require "application_serializer/version"
require "application_serializer/context"
require "application_serializer/base"

module ApplicationSerializer
  DEFAULT_CONTEXT = :default
  DEFAULT_OPTIONS = { scope: nil }
end
