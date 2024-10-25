# frozen_string_literal: true

# ApplicationRecord serves as the base class for all models in the application.
# It inherits from ActiveRecord::Base and can be used to add shared functionality
# across all models.
class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
