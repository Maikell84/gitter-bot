class BaseService
  def initialize(calling_class)
    @gitter_bot = calling_class
    @active = false
    @rooms = []
  end

  def activate(target_room, active)
    # Start service, if it is not active, yet
    start_service if active && !@active
    if active
      @rooms.push(target_room) unless @rooms.include? target_room
      @active = active
    else
      @rooms.delete_if {|x| x == target_room }
      @active = false if @rooms.nil?
    end
  end

  def start_service
    raise 'implement in subclass'
  end
end
