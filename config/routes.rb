# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :departments
resources :resources
resources :issue_resources

post 'resources/settings/trackers', :to => 'resources#trackers'
