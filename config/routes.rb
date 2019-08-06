Rails.application.routes.draw do
  root to: 'visitors#index'
  get 'visitors/assign', :to => 'visitors#assign', as: :visitors_assign
end
