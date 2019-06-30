resources :zidox, only: [:create, :update, :destroy] do
  collection do
    post :settings
  end
end
resources :issue_zidox

get 'projects/:project_id/zidox', to: 'project_zidox#index'
post 'projects/:project_id/zidox', to: 'project_zidox#create'
