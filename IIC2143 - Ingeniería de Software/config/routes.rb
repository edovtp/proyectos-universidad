Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#index'

  # Administrador
  get 'admin', to: 'admin#index'

  scope '/admin' do
    get 'usuarios', to: 'perfil#index', as: 'admin_usuarios'
    get 'locales', to: 'admin#ver_locales', as: 'admin_locales'
    delete 'locales/:local_id', to: 'admin#eliminar_local', as: 'admin_delete_local'
    get 'aceptar_locales', to: 'admin#aceptar_locales', as: 'admin_aceptar_locales'
    patch 'aceptar_locales/:local_id', to: 'admin#aceptar_local', as: 'admin_aceptar_local'
    resources :comunas, controller: 'communes'
    resources :gustos, controller: 'interests'
    resources :comentarios, controller: 'comments', only: %i[index destroy]
  end

  # Locales, Menus y Comentarios
  resources :locales, controller: 'locals', as: 'local' do
    resources :menus, only: %i[new create edit update destroy]
    resources :comentarios, controller: 'comments', only: %i[new create destroy]
    resources :valoraciones, controller: 'valuations', only: %i[edit update destroy]
  end
  # Perfil
  # Create
  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations' }

  # Ver menus
  get 'locales/:local_id/edit/menus', to: 'menus#show', as: :local_menues

  # Imagenes del local
  get 'locales/:local_id/edit/imagenes', to: 'locals#images', as: :local_images
  patch 'locales/:local_id/edit/imagenes', to: 'locals#update_images', as: :local_add_images
  delete 'locales/:local_id/edit/imagenes/:image_id', to: 'locals#delete_images',
                                                      as: :local_delete_images

  # Ver comentarios
  get 'perfil/:user_id/comentarios', to: 'comments#show', as: :perfil_comentarios
  # Ver valoraciones pendientes
  get 'perfil/:user_id/valoraciones', to: 'perfil#valuations', as: :perfil_valuations

  # Read perfil
  get 'perfil/:user_id', to: 'perfil#show', as: :perfil

  # Update perfil
  get 'perfil/:id/edit', to: 'perfil#edit', as: :perfil_edit
  patch 'perfil/:id', to: 'perfil#update'
  put 'perfil/:id', to: 'perfil#update'

  # Update interes
  patch 'perfil_interest/:id', to: 'perfil#update_interest', as: :perfil_edit_interest
  get 'perfil/:id/:idinterest', to: 'perfil#delete_interest', as: :perfil_delete_interest

  # Update Profile Avatar
  patch 'perfil_avatar/:user_id', to: 'perfil#update_avatar', as: :perfil_update_avatar
  delete 'perfil_avatar/:user_id', to: 'perfil#delete_avatar', as: :perfil_delete_avatar

  # Delete perfil
  delete 'perfil/:id', to: 'perfil#destroy'

  # Match
  # Mostrar perfiles
  get 'match/:id', to: 'matches#index', as: :match
  # Mostrar informacion de los matches del usuario
  get 'match/:id/info', to: 'matches#show', as: :match_info

  # Create match
  get 'match/:id/:idsolicitado', to: 'matches#new', as: :match_new
  # Aceptar/Rechazar match_request
  patch 'perfil/:id/:id_matchrequest', to: 'matches#accept_match', as: :perfil_accept_match

  # CITAS
  # Proponer Cita
  get 'appointment/:id', to: 'appointment#new', as: :new_appointment

  # Crear Cita
  post 'appointment/:id', to: 'appointment#create', as: :create_appointment

  # Aceptar Cita
  put 'perfil/:id/:appointment_id', to: 'appointment#accept', as: :accept_appointment
end
