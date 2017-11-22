class LeetService
  def initialize(calling_class)
    @gitter_bot = calling_class
    @active = false
    @leet_rooms = []
  end

  def activate(target_room, active)
    # Start service, if it is not active, yet
    start_service if active && !@active
    if active
      @leet_rooms.push(target_room) unless @leet_rooms.include? target_room
      @active = active
    else
      @leet_rooms.delete_if {|x| x == target_room }
      @active = false if @leet_rooms.nil?
    end
  end

  def start_service
    @thread = Thread.new do
      while @active
        current_time = Time.new

        message = if current_time.hour == 13 && current_time.min == 37
                    'Look at the time! It\'s :one: :three: : :three: :seven: !'
                  else
                    nil
                  end

        @leet_rooms.each do |room|
          @gitter_bot.send_message(room, message)
        end unless message.nil?

        sleep 60
      end

      @thread.kill
    end
  end
end
