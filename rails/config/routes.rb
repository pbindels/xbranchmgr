Branchmgr::Application.routes.draw do
  resources :deploy_envs


  get "git_hub/authorize"

  get "git_hub/callback"


  match '/get_branches' => 'branches#get_branches', :as => 'get_branches'
  match '/create_repo' => 'branches#create_repo', :as => 'create_new_repo'
  match '/delete_repo' => 'branches#delete_repo', :as => 'delete_repo'
  match '/list_branches' => 'branches#list_branches', :as => 'list_branches'
  match '/delete_branch' => 'branches#delete_branch', :as => 'delete_branch'
  match '/find_branch' => 'branches#find_branch', :as => 'find_branch'
  match '/delete_branch_across_repos' => 'branches#delete_branch_across_repos', :as => 'delete_branch_across_repos'
  match '/git_hub_auth' => 'git_hub#authorize', :as => 'git_hub_auth'
  get 'git_hub/authorize'
  get 'branches/list_branches'
  get 'branches/get_branches'
  get 'branches/delete_branch'
  get 'branches/find_branch'
  get 'branches/create_repo'
  get 'branches/delete_repo'
  post 'branches/create_new_repository'
  post 'branches/delete_repository'
  post 'branches/delete_branch_across_repos'
  post 'branches/find_branch_across_repos'
  post 'branches/index'
  post 'branches/form5_confirm_delete'
  post 'branches/do_task'

  get 'branches/test_js'
  get 'branches/test_progress'
  get 'branches/test_git'
  resources :branches
  resources :github



  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
#   root :to => 'branches#new'
   root :to => 'git_hub#authorize'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
