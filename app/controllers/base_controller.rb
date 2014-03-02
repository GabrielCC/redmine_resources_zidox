class BaseController < ApplicationController
	include ResourcesHelper
	layout "admin"
	 before_filter :authorize_global
end