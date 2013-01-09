desc "check if there are any new photos, if so we save them"
task :check_if_new_photos_available => :environment do
	config = YAML.load_file("./global_config.yml") rescue nil || {}

	Dropbox::API::Config.app_key    = config["dropbox_key"]
	Dropbox::API::Config.app_secret = config["dropbox_secret"]

	client = Dropbox::API::Client.new(:token => config["dropbox_oauth_token"], :secret => config["dropbox_oauth_secret"])
	last_photo = Photo.order("modified_at").last
	delta = client.delta(last_photo.cursor)
	delta.entries.each do |file|
		photo = Photo.where(:path => file.path)
		if photo.empty?
			media = file.direct_url
			photo = Photo.new(:path => file.path, :modified_at => file.modified, :media_url => media.url, :media_url_expires_at => media.expires, :media_url_fetched_at => DateTime.now, :cursor => delta.cursor)

			# all the smart stuff below comes from edouard
			# https://gist.github.com/1787879
			
			TOP_N = 10           # Number of swatches
			 
			# Create a 1-row image that has a column for every color in the quantized
			# image. The columns are sorted decreasing frequency of appearance in the
			# quantized image.
			def sort_by_decreasing_frequency(img)
			  hist = img.color_histogram
			  # sort by decreasing frequency
			  sorted = hist.keys.sort_by {|p| -hist[p]}
			  new_img = Magick::Image.new(hist.size, 1)
			  new_img.store_pixels(0, 0, hist.size, 1, sorted)
			end
			 
			def get_pix(img)
			  palette = Magick::ImageList.new
			  pixels = img.get_pixels(0, 0, img.columns, 1)
			  colours = []
			  pixels.each do |p|
			  	# perceived brightness
			  	brightness = (0.299*p.red + 0.587*p.green + 0.114*p.blue)
			    colour = p.to_color(Magick::AllCompliance, false, 8, true)
			    colours << [colour, brightness]
			  end
			  # sort them by brightness
			  colours.sort_by!{|k|k[1]}

			  # now we just want to keep the actual hex value
			  colours.each do |array|
					array.each_with_index do |a, i|
						if i == 1
							array.delete a 
						end  
					end  
				end 
				colours.flatten!
			  return colours
			end
			 
			original = Magick::Image.read(media.url).first
			 
			# reduce number of colors
			quantized = original.quantize(TOP_N, Magick::RGBColorspace)
			 
			# Create an image that has 1 pixel for each of the TOP_N colors.
			normal = sort_by_decreasing_frequency(quantized)
			photo.colours = get_pix(normal).to_s
			photo.save
		end
	end

end