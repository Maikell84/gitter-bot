class TimeService
  def initialize(calling_class)
    @gitter_bot = calling_class
    @active = false
    @time_rooms = []
  end

  def activate(target_room, active)
    # Start service, if it is not active, yet
    start_service if active && !@active
    if active
      @time_rooms.push(target_room) unless @time_rooms.include? target_room
      @active = active
    else
      @time_rooms.delete_if {|x| x == target_room }
      @active = false if @time_rooms.nil?
    end
  end

  def start_service
    @thread = Thread.new do
      while @active
        current_time = Time.new
        time = if current_time.min.zero?
                 ":clock#{current_time.strftime('%l').strip!}:"
               elsif current_time.min == 30
                 ":clock#{current_time.strftime('%l').strip!}30:"
               else
                 nil
               end

        @time_rooms.each do |room|
          @gitter_bot.send_message(room, time)
        end unless time.nil?

        sleep 60
      end

      @thread.kill
    end
  end
end
