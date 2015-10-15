module LoginSupport
  private

  def login_as_admin
    admin = create :admin
    User.current = admin
    @request.session[:user_id] = admin.id
  end

  def login_as_author
    User.current = @author
    @request.session[:user_id] = @author.id
  end
end
