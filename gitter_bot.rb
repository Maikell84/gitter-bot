require 'eventmachine'
require 'em-http'
require 'json'
require 'net/http'
require 'open-uri'
require 'giphy'
require_relative 'time_service'

class GitterBot
	Giphy::Configuration.configure do |config|
	  config.api_key = ENV['GIPHY_API_KEY']
	end

	def initialize
    @debug = false
		@token = ENV['GITTER_TOKEN']
		room_id = ENV['GITTER_ROOM_ID']
		stream_url = "https://stream.gitter.im/v1/rooms/#{room_id}/chatMessages"
		@send_url = "https://api.gitter.im/v1/rooms/#{room_id}/chatMessages"
    @time_service = TimeService.new(self)
		http = EM::HttpRequest.new(stream_url, keepalive: true, connect_timeout: 0, inactivity_timeout: 0)

		EventMachine.run do
		  req = http.get(head: {'Authorization' => "Bearer #{@token}", 'accept' => 'application/json'})
		  req.stream do |chunk|
		    unless chunk.strip.empty?
		      @message = JSON.parse(chunk)
					handle_message
		    end
		  end
		end
	end

	def handle_message
	  p [:message, @message] if @debug
	  if @message['text'].downcase.include? 'tell a joke'
	  	tell_a_joke
	  elsif @message['text'].start_with? 'gif'
	  	show_gif(@message['text'])
    elsif @message['text'].downcase.start_with? 'deactivate time service'
      toggle_time_service(false)
    elsif @message['text'].downcase.start_with? 'activate time service'
	    toggle_time_service(true)
    elsif @message['text'].downcase.include? 'but why'
       but_why
	  end
	end

	def tell_a_joke
		response = open('https://icanhazdadjoke.com/', 'Accept' => 'application/json').read
		joke = JSON.parse(response)['joke']
		send_message(joke)
	end

	def show_gif(text)
		text.slice!('gif')
		begin
			g = Giphy.random(text)
			send_message('![](' + g.image_url.to_s + ')')
		rescue
			g = Giphy.random('404')
			send_message('![](' + g.image_url.to_s + ')')
		rescue
			send_message('*no gif found*')
		end
	end

  def but_why
    send_message('![](https://media.giphy.com/media/1M9fmo1WAFVK0/giphy.gif)')
  end

	def send_message(text)
		uri = URI(@send_url)
		req = Net::HTTP::Post.new(uri)
		req['Authorization'] = "Bearer #{@token}"
		req['Accept'] = 'application/json'
		req['Content-Type'] = 'application/json'
		req.set_form_data('text' => text)

		res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
			http.request(req)
		end

		case res
		when Net::HTTPSuccess, Net::HTTPRedirection
		  # Message successfully sent
		else
			puts 'An HTTP error occured while trying to send a message'
		  puts res.value
		end
	end

  def toggle_time_service(active)
    @time_service.activate(active)
    active_display = active == true ? 'on' : 'off'
    send_message("Time Service is #{active_display}")
  end
end

GitterBot.new
