ActionController::Routing::Routes.draw do |map|

  map.root :controller => 'welcome', :action => 'index'
  
  map.resources :accounts
  map.dashboard '/dashboard', :controller => 'accounts', :action => 'index'

  map.resources :projects do |projects|
    projects.resources :features
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
