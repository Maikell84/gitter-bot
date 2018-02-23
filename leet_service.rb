require_relative 'base_service'

class LeetService < BaseService
  def start_service
    @thread = Thread.new do
      while @active
        current_time = Time.new

        if current_time.hour == 13 && current_time.min == 37
          @rooms.each do |room|
            @gitter_bot.send_message(room, 'Look at the time! It\'s :one: :three: : :three: :seven: !')
          end
        end

        sleep 60
      end

      @thread.kill
    end
  end
end
