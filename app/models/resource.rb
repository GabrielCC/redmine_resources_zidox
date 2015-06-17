class Resource < ActiveRecord::Base
  belongs_to :division
  has_many :project_resource
  has_many :project, through: :project_resource
  attr_accessible :code, :name, :division
  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true
  validates :division, presence: true

  def self.find_or_create_by_params(params)
  	resource = self.find_or_initialize_by_name_and_code(params[:name], params[:code])
  	if resource.new_record?
  		division = Division.find_or_initialize_by_name(params[:division_name])
  		if division.new_record?
  			division.save
  		end
  		resource.division = division
  		resource.save!
  	end
  	resource
  end
end
