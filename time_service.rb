class TimeService
  def initialize(calling_class)
    @gitter_bot = calling_class
    @active = false
  end

  def activate(active)
    @active = active
    start_service if active
  end

  def start_service
    @thread = Thread.new {
      while @active
        time = nil
        case Time.new.hour
        when 0, 12
          if Time.new.min == 0
            time = ':clock12:'
          elsif Time.new.min == 30
            time = ':clock1230:'
          end
        when 1, 13
          if Time.new.min == 0
            time = ':clock1:'
          elsif Time.new.min == 30
            time = ':clock130:'
          elsif Time.new.min == 37 && Time.new.hour == 13
            time = 'Look at the time! It\'s :one: :three: : :three: :seven: !'
          end
        when 2, 14
          if Time.new.min == 0
            time = ':clock2:'
          elsif Time.new.min == 30
            time = ':clock230:'
          end
        when 3, 15
          if Time.new.min == 0
            time = ':clock3:'
          elsif Time.new.min == 30
            time = ':clock330:'
          end
        when 4, 16
          if Time.new.min == 0
            time = ':clock4:'
          elsif Time.new.min == 30
            time = ':clock430:'
          end
        when 5, 17
          if Time.new.min == 0
            time = ':clock5:'
          elsif Time.new.min == 30
            time = ':clock530:'
          end
        when 6, 18
          if Time.new.min == 0
            time = ':clock6:'
          elsif Time.new.min == 30
            time = ':clock630:'
          end
        when 7, 19
          if Time.new.min == 0
            time = ':clock7:'
          elsif Time.new.min == 30
            time = ':clock730:'
          end
        when 8, 20
          if Time.new.min == 0
            time = ':clock8:'
          elsif Time.new.min == 30
            time = ':clock830:'
          end
        when 9, 21
          if Time.new.min == 0
            time = ':clock9:'
          elsif Time.new.min == 30
            time = ':clock930:'
          end
        when 10, 22
          if Time.new.min == 0
            time = ':clock10:'
          elsif Time.new.min == 30
            time = ':clock1030:'
          end
        when 11, 23
          if Time.new.min == 0
            time = ':clock11:'
          elsif Time.new.min == 30
            time = ':clock1130:'
          end
        end
        puts Time.new
        @gitter_bot.send_message(time) unless time.nil?
        sleep 60
      end

      @thread.kill
    }
  end
end
