resources :resources, only: [:create, :update, :destroy] do
  collection do
    post :settings
  end
end
resources :issue_resources

get 'projects/:project_id/resources', to: 'project_resources#index'
post 'projects/:project_id/resources', to: 'project_resources#create'
