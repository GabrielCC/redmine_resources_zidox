resources :resources, only: [:create, :update, :destroy]
resources :issue_resources

post 'resources/settings/trackers', to: 'resources#trackers'

post 'projects/:project_id/resources', to: 'project_resources#create'
get 'projects/:project_id/resources', to: 'project_resources#index'
