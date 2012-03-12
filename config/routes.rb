# -*- encoding : utf-8 -*-

ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  map.categories(
    'sortiment/',
    :controller => 'categories',
    :action => 'index')
  map.category(
    'sortiment/:category',
    :controller => 'categories',
    :action => 'subindex')
  map.ask_destroy_category(
    'kategorie/:category/loeschen',
    :controller => 'categories',
    :action => 'ask_destroy',
    :conditions => {:method => :get})
  map.subcategory(
    'sortiment/:category/:subcategory',
    :controller => 'articles',
    :action => 'index')
  map.ask_destroy_subcategory(
    'kategorie/:category/:subcategory/loeschen',
    :controller => 'categories',
    :action => 'ask_destroy',
    :conditions => {:method => :get})
  map.resources :categories, :as => 'kategorie'
  map.reorder_categories(
    'kategorie/sortieren',
    :controller => 'categories',
    :action => 'reorder')
  
  map.edit_articles_order(
    'sortiment/:category/:subcategory/umsortieren',
    :controller => 'articles',
    :action => 'edit_order',
    :conditions => {:method => :get})
  map.reorder_articles(
    'sortiment/:category/:subcategory/sortieren',
    :controller => 'articles',
    :action => 'reorder',
    :conditions => {:method => :put})
  map.ask_destroy_article(
    'sortiment/:category/:subcategory/:article/loeschen',
    :controller => 'articles',
    :action => 'ask_destroy',
    :article => Article::ARTICLE_NUMBER_FORMAT)
  map.resources :articles, :as => 'artikel' do |articles|
    articles.resource :picture, :as => 'bild', :controller => 'picture' do |picture|
      picture.download 'download/:style.:extension', :action => 'pictures', :controller => 'picture'
      picture.download 'download', :action => 'pictures', :controller => 'picture'
    end
  end
  
  map.resources :fair_dates, :as => 'messetermine'
  map.my_profile(
    'profil',
    :controller => 'profiles',
    :action => 'show_mine',
    :conditions => {:method => :get})
  map.edit_my_profile(
    'profil/bearbeiten',
    :controller => 'profiles',
    :action => 'edit_mine',
    :conditions => {:method => :get})
  map.update_my_profile(
    'profil',
    :controller => 'profiles',
    :action => 'update_mine',
    :conditions => {:method => :put})
  map.resources :profiles, :as => 'profile'
  
  map.resource(:session, :as => 'sitzung',
      :collection => {:destroy => :get},
      :path_names => {:new => 'anmelden', :destroy => 'abmelden'}) do |session|
    session.resources(
      :secure_user_requests,
      :as => 'sichere_benutzeranfrage',
      :member => {:destroy => :get},
      :only => [:edit, :update, :destroy],
      :path_names => {:destroy => 'abbrechen'},
      :name_prefix => nil)
  end
  
  map.stylesheet(
    'stylesheets/*path',
    :controller => 'static',
    :action => 'stylesheet',
    :conditions => {:method => :get}
  )
  
  map.root :path => 'ueber_uns', :controller => 'static', :action => 'show', :welcome => true
  map.static(
    '*path',
    :controller => 'static',
    :action => 'show',
    :conditions => {:method => :get}
  )
end
