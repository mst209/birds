# frozen_string_literal: true

# ApplicationRecord
class ApplicationRecord < ActiveRecord::Base
  extend T::Sig
  primary_abstract_class
end
