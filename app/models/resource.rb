class Resource < ActiveRecord::Base
  belongs_to :division
  has_many :project_resource
  has_many :project, through: :project_resource
  has_many :issue_resources
  attr_accessible :code, :name, :division
  validates :name, uniqueness: true, presence: true
  validates :code, uniqueness: true, presence: true
  validates :division, presence: true

  def self.find_or_create_by_params(params)
  	resource = where(name: params[:name], code: params[:code])
      .first_or_initialize
  	if resource.new_record?
  		division = Division.where(name: params[:division_name])
        .first_or_initialize
  		if division.new_record?
  			division.save
  		end
  		resource.division = division
  		resource.save!
  	end
  	resource
  end
end
