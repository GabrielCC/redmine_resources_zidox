class Resource < ActiveRecord::Base
  belongs_to :department
  has_many :member_resource
  has_many :member, :through => :member_resource
  attr_accessible :code, :name, :department
  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true
  validates :department, presence: true
end
