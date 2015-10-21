class Division < ActiveRecord::Base
  has_many :resources
  validates :name, uniqueness: true
end
