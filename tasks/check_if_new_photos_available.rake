desc "check if there are any new photos, if so we save them"
task :check_if_new_photos_available => :environment do
	config = YAML.load_file("./global_config.yml") rescue nil || {}

	Dropbox::API::Config.app_key    = config["dropbox_key"]
	Dropbox::API::Config.app_secret = config["dropbox_secret"]

	client = Dropbox::API::Client.new(:token => config["dropbox_oauth_token"], :secret => config["dropbox_oauth_secret"])
	client.ls.each do |file|
		photo = Photo.where(:path => file.path)
		if photo.empty?
			media = file.direct_url
			photo = Photo.new(:path => file.path, :modified_at => file.modified, :media_url => media.url, :media_url_expires_at => media.expires, :media_url_fetched_at => DateTime.now)
			photo.save 
		end
	end

end