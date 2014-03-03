# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :departments
resources :resources

post 'resources/settings/trackers', :to => 'resources#trackers'
