# frozen_string_literal: true

# The ApplicationRecord class serves as the base class for all models in the application
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
