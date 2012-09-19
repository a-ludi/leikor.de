# -*- encoding : utf-8 -*-

ActionController::Routing::Routes.draw do |map|
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
  map.resources :categories, :as => 'kategorie', :except => [:index, :show]
  map.reorder_categories(
      'kategorie/sortieren',
      :controller => 'categories',
      :action => 'reorder',
      :conditions => {:method => :post})
  
  map.edit_articles_order(
      'sortiment/:category/:subcategory/umsortieren',
      :controller => 'articles',
      :action => 'edit_order',
      :conditions => {:method => :get})
  map.reorder_articles(
      'sortiment/:category/:subcategory/sortieren',
      :controller => 'articles',
      :action => 'reorder',
      :conditions => {:method => :post})
  map.ask_destroy_article(
      'sortiment/:category/:subcategory/:article/loeschen',
      :controller => 'articles',
      :action => 'ask_destroy',
      :article => Article::ARTICLE_NUMBER_FORMAT)
  map.resources :articles, :as => 'artikel', :except => [:show] do |articles|
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
  map.edit_password(
      'profil/passwort/bearbeiten',
      :controller => 'profiles',
      :action => 'edit_password',
      :conditions => {:method => :get})
  map.password(
      'profil/passwort',
      :controller => 'profiles',
      :action => 'update_password',
      :conditions => {:method => :put})
  map.resources :profiles, :as => 'profile', :except => [:new] do |profiles|
    profiles.resources :groups, :as => 'gruppen', :only => [:create, :update, :destroy]
  end
  map.suggest_groups(
      'gruppen/vorschlaege',
      :controller => 'groups',
      :action => 'suggest',
      :conditions => {:method => :get})
  map.new_customer_profile(
      'profile/neu/kunde',
      :controller => 'profiles',
      :action => 'new',
      :type => 'Customer',
      :conditions => {:method => :get})
  map.new_employee_profile(
      'profile/neu/mitarbeiter',
      :controller => 'profiles',
      :action => 'new',
      :type => 'Employee',
      :conditions => {:method => :get})
  
  map.new_reset_password_request(
      'passwort-zuruecksetzen',
      :controller => 'secure_user_requests',
      :action => 'new',
      :type => 'SecureUserRequest::ResetPassword',
      :conditions => {:method => :get})
  map.confirm_registration_request(
      'registrierung-bestaetigen',
      :controller => 'secure_user_requests',
      :action => 'create',
      :type => 'SecureUserRequest::ConfirmRegistration',
      :conditions => {:method => :post})
  map.with_options :controller => 'sessions' do |session|
    session.destroy_session 'sitzung/abmelden', :action => 'destroy', :conditions => {:method => :get}
    session.new_session 'sitzung/anmelden', :action => 'new', :conditions => {:method => :get}
    session.session 'sitzung', :action => 'create', :conditions => {:method => :post}
  end

  map.resources(
      :secure_user_requests,
      :as => 'sichere-benutzeranfrage',
      :member => {:destroy => :get}, # FIXME shouldn't use GET on destroy action
      :except => [:index, :show, :new],
      :path_names => {:destroy => 'abbrechen'},
      :name_prefix => nil)
  
  map.resources(
      :blog_posts,
      :as => 'blog',
      :member => {
          :mail => [:post, :get],
          :publish => [:post, :get]},
      :collection => {
          :readers => :get},
      :path_names => {
          :new => 'schreiben',
          :mail => 'mailen',
          :publish => 'veroeffentlichen',
          :readers => 'leser'},
      :controller => 'blog')
  
  map.stylesheet(
      'stylesheets/*path',
      :controller => 'static',
      :action => 'stylesheet',
      :conditions => {:method => :get})
  
  map.root :blog_posts
  map.static(
      '*path',
      :controller => 'static',
      :action => 'show',
      :conditions => {:method => :get})
  if RAILS_ENV == 'test'
    map.test_method(
        'test/:controller/test_method',
        :action => 'test_method')
    map.set_title(
        'test/set_title',
        :controller => 'application',
        :action => 'set_title')
  end
end
