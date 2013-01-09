desc "fetch new media urls for those photos that need them"
task :fetch_new_media_urls => :environment do
	config = YAML.load_file("./global_config.yml") rescue nil || {}

	# we fetch the files ordered by the modification date in Dropbox
	photos = []
	if config["photos_to_display"] == 1
		photos << Photo.order("modified_at DESC").first
	else
		photos = Photo.order("modified_at DESC").limit(config["photos_to_display"])
	end

	# settings first so we don't repeat them if we increase the photo limit

	Dropbox::API::Config.app_key    = config["dropbox_key"]
	Dropbox::API::Config.app_secret = config["dropbox_secret"]

	client = Dropbox::API::Client.new(:token => config["dropbox_oauth_token"], :secret => config["dropbox_oauth_secret"])

	photos.each do |photo|
		# I can never remeber how to do time maths in Ruby
		time_left = (photo.media_url_expires_at - Time.now)/60
		# can't guarantee none of the cron jobs will fail so let's give it a generous window
		if time_left > 50
			# don't need to do anything
		else
			# time to refresh the media url
			file = client.find photo.path
			media = file.direct_url
			photo.media_url = media.url
			photo.media_url_expires_at = media.expires
			photo.media_url_fetched_at = DateTime.now
			photo.save
		end
	end

end