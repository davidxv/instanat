Instanat.controllers :photo do
  layout :app

  get :index do
  end

  get :latest, :map => "/" do
    @photos = Photo.order("modified_at DESC").limit(Instanat.settings.photos_to_display)
    render 'photo/latest'
  end

end
