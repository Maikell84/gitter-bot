require 'eventmachine'
require 'em-http'
require 'json'
require 'net/http'
require 'open-uri'
require 'giphy'
require 'imgflip'
require_relative 'time_service'
require_relative 'leet_service'

class GitterBot
	Giphy::Configuration.configure do |config|
	  config.api_key = ENV['GIPHY_API_KEY']
	end

	def initialize
    @debug = false
		@token = ENV['GITTER_TOKEN']
    room_ids = [ENV['GITTER_ROOM_ID']]
		threads = []
    @time_service = TimeService.new(self)
    @leet_service = LeetService.new(self)

    room_ids.each_with_index  do |room, i|
      threads.push( Thread.new { start_listener(room) } )
    end

    threads.each do |thread|
      thread.join
    end
	end

  def start_listener(room)
    puts "Start listening for new messages in room #{room}"
    stream_url = "https://stream.gitter.im/v1/rooms/#{room}/chatMessages"
    http = EM::HttpRequest.new(stream_url, keepalive: true, connect_timeout: 0, inactivity_timeout: 0)

    EventMachine.run do
      req = http.get(head: {'Authorization' => "Bearer #{@token}", 'accept' => 'application/json'})
      req.stream do |chunk|
        unless chunk.strip.empty?
          begin
            @message = JSON.parse(chunk)
            handle_message(room)
          rescue JSON::ParserError
            puts "Rescue JSON parser error: JSON: #{chunk}"
          end
        end
      end
    end
  end

	def handle_message(target_room)
	  p [:message, @message] if @debug
    p "Target room = #{target_room}" if @debug
	  if @message['text'].downcase.include? 'tell a joke'
	  	tell_a_joke(target_room)
	  elsif @message['text'].downcase.start_with? 'gif'
	  	show_gif(target_room, @message['text'])
    elsif @message['text'].downcase.start_with? 'deactivate time service'
      toggle_service(@time_service, target_room, false)
    elsif @message['text'].downcase.start_with? 'activate time service'
	    toggle_service(@time_service, target_room, true)
    elsif @message['text'].downcase.start_with? 'deactivate leet service'
      toggle_service(@leet_service, target_room, false)
    elsif @message['text'].downcase.start_with? 'activate leet service'
      toggle_service(@leet_service, target_room, true)
    elsif @message['text'].downcase.include? 'but why'
       but_why(target_room)
	  end
    spongebob(target_room, @message['text']) unless @message['text'].include? 'http://i.imgflip.com'
	end

  def spongebob(target_room, text)
    text.slice!('spongebob')
    text.gsub!(/\w/).with_index{|s, i| i.even? ? s.upcase : s.downcase}
    post = Net::HTTP.post_form(URI.parse('https://api.imgflip.com/caption_image'),template_id: 102156234, text0: '', text1: '', 'boxes[0][text]': '', 'boxes[1][text]': text,username: "imgflip_hubot", password: "imgflip_hubot")
    send_message(target_room, JSON.parse(post.body)["data"]["url"])
  end

	def tell_a_joke(target_room)
		response = open('https://icanhazdadjoke.com/', 'Accept' => 'application/json').read
		joke = JSON.parse(response)['joke']
		send_message(target_room, joke)
	end

	def show_gif(target_room, text)
		text.slice!('gif')
		begin
			g = Giphy.random(text)
			send_message(target_room, g.image_url.to_s)
		rescue
			g = Giphy.random('404')
			send_message(target_room, g.image_url.to_s)
		rescue
			send_message(target_room, '*no gif found*')
		end
	end

  def but_why(target_room)
    send_message(target_room, 'https://media.giphy.com/media/1M9fmo1WAFVK0/giphy.gif')
  end

	def send_message(target_room, text)
    send_url = "https://api.gitter.im/v1/rooms/#{target_room}/chatMessages"
		uri = URI(send_url)
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

  def toggle_service(service, room, active)
    service.activate(room, active)
    send_message(room, "#{service.class.name} is #{active ? 'on' : 'off'}")
  end
end

GitterBot.new
