require_relative 'base_service'

class TimeService < BaseService
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

        @rooms.each do |room|
          @gitter_bot.send_message(room, time)
        end unless time.nil?

        sleep 60
      end

      @thread.kill
    end
  end
end
