Rails.application.routes.draw do

#  get '/'                  => 'gunclocks#index'
#  root :to => 'gunclocks#index'

  get 'gunclocks/index'    => 'gunclocks#index'
  get 'gunclocks'          => 'gunclocks#index'

#  get 'gunclocks/show'
  get 'gunclocks/show/:id' => 'gunclocks#show'
#  get 'gunclocks/:id'      => 'gunclocks#show'

  get 'gunclocks/edit/:id' => 'gunclocks#edit'
  get 'gunclocks/:id/edit' => 'gunclocks#edit'

  get 'gunclocks/new'      => 'gunclocks#new'

  put   'gunclocks/:id'    => 'gunclocks#update'
  patch 'gunclocks/:id'    => 'gunclocks#update'

  post 'gunclocks'         => 'gunclocks#create'
  delete 'gunclocks/:id'   => 'gunclocks#destroy'


  get 'gunclocks/api/index.:format' => 'gunclocks#api_index'
  get 'gunclocks/api/show/:id.:format' => 'gunclocks#api_show'

  get 'gunclocks/getGunClock' => 'gunclocks#getGunClock'

  get 'users/index'

  get 'users/show/:username' => 'users#show'

  get 'gunclocks/tweetGunclock'    => 'gunclocks#tweetGunclock'
  get 'gunclocks/tweet'            => 'gunclocks#tweet'
  get 'gunclocks/kafkaConsumer'    => 'gunclocks#kafkaConsumer'
  get 'gunclocks/kafkaGunclock', :to => redirect('/kafkaGunclock.html')
  get 'gunclocks/kafkaGunclockToDjango', :to => redirect('/kafkaGunclockToDjango.html')

  get 'gunclocks/kafkaConsumerDjango', :to => redirect('http://gunclocks-django.herokuapp.com/gunclocks/kafkaConsumer/')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
