class Resource < ActiveRecord::Base
  belongs_to :department
  attr_accessible :code, :name
  validates :name, uniqueness: true
  validates :code, uniqueness: true
end
