Instanat.controllers :photo do
  layout :app

  get :index do
  end

  get :latest, :map => "/" do
    @photos = Photo.order("modified_at DESC").limit(1)
    render 'photo/latest'
  end

end
