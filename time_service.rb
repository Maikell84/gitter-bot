class TimeService
  def initialize(calling_class)
    @gitter_bot = calling_class
    @active = false
  end

  def activate(active)
    # Start service, if it is not active, yet
    start_service if active && !@active
    @active = active
  end

  def start_service
    @thread = Thread.new {
      while @active
        current_time = Time.new
        time = if current_time.min.zero?
               ":clock#{current_time.strftime('%-I')}:"
             elsif current_time.min == 30
               ":clock#{current_time.strftime('%-I')}30:"
             elsif current_time.hour == 13 && current_time.min == 37
               'Look at the time! It\'s :one: :three: : :three: :seven: !'
             else
              nil
             end

        puts current_time if @debug
        @gitter_bot.send_message(time) unless time.nil?
        sleep 60
      end

      @thread.kill
    }
  end
end
