ZuoraQuery::Application.routes.draw do
  resources :connectors

  root :to => 'query_tool#index'

  match 'query' => 'query_tool#query'

end
