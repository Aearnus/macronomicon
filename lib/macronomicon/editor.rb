require "curses"

class FilePane
  def initialize
    @current_file = nil
    @lines = []
    @cursor_pos = [0,0]    
    @scroll_pos = 0
    @scroll_limits = [4, 20]
  end

  def draw(top_left, bottom_right)
    line_screen = @lines[@scroll_pos .. @scroll_pos + (bottom_right[0] - top_left[0])]
    Curses::setpos *top_left
    line_screen.each do |l|
      Curses::addstr l
      Curses::addstr "\n"
    end
    Curses::setpos(top_left[0] + @cursor_pos[0] - @scroll_pos, top_left[1] + @cursor_pos[1])
    Curses::addch "_"
  end

  def load_file(filename)
    @current_file = File.open filename, "rw"
    # TODO: check file validity
    @cursor_pos = [0,0]
    @lines = []
    @current_file.each_line do |l|
      @lines << l
    end
  end

  def scroll_down
    if @scroll_pos < @lines.length
      @scroll_pos += 1
    end
  end

  def scroll_up
    if @scroll_pos > 0
      @scroll_pos -= 1
    end
  end

  def scroll_by_limits
    if @cursor_pos[0] - @scroll_pos < @scroll_limits[0]
      $NOTIF_PANE.send_notif("Scrolled up!")
      scroll_up
    elsif @cursor_pos[0] - @scroll_pos > @scroll_limits[1]
      $NOTIF_PANE.send_notif("Scrolled down!")
      scroll_down
    end
  end

  def type_key(key)
    while (@lines[@cursor_pos[0]].nil?) do @lines << ""; end
    while (@lines[@cursor_pos[0]][@cursor_pos[1]].nil?) do @lines[@cursor_pos[0]] << " "; end
    if key == "\n"
      @lines << ""
      @cursor_pos[0] += 1
      @cursor_pos[1] = 0
      scroll_by_limits
    else
      @lines[@cursor_pos[0]][@cursor_pos[1]] = key
      @cursor_pos[1] += 1
    end
  end
end


# there can only be 1 notifpane registered
$NOTIF_PANE = nil
class NotifPane
  def initialize
    @current_notif = "Hello, world!"
    $NOTIF_PANE = self
  end

  def draw(top_left, bottom_right)
    Curses::setpos *top_left
    Curses::addstr @current_notif
  end

  def send_notif(text)
    @current_notif = text
  end
end

class PaneLayout
  attr_accessor :layout
  def initialize(orientation=:horizontal)
    @orientation = orientation
    # this is an n-tuple containing both sides of the editor
    # either top & bottom or left & right.
    # each element is either a *Pane or another PaneLayout.
    # it doesn't actually matter though -- they both have
    # the same #draw prototypical method
    @layout = []
  end

  def draw(top_left, bottom_right)
    case @orientation
    when :horizontal
      offset = 0
      @layout.each do |p|
        if p[:chars].nil?
          p[:pane].draw(
            [top_left[0], top_left[1] + offset], 
            bottom_right)
        else
          p[:pane].draw(
            [top_left[0], top_left[1] + offset], 
            [bottom_right[0], bottom_right[1] + offset + p[:chars]]) 
        end
        offset += bottom_right[1] - top_left[1]
      end
    when :vertical
      offset = 0
      @layout.each do |p|
        if p[:chars].nil?
          p[:pane].draw(
            [top_left[0] + offset, top_left[1]],
            bottom_right)
        else
          p[:pane].draw(
            [top_left[0] + offset, top_left[1]],
            [bottom_right[0] + offset + p[:chars], bottom_right[1]])
        end
        offset += bottom_right[0] - top_left[0]
      end
    end
  end

  def add_pane(pane, chars)
    @layout << {chars: chars, pane: pane}
  end

  def type_key(key)
    # TODO: see other type_key
    @layout[0][:pane].type_key key
  end
end



class Editor
  attr_accessor :tabs
  def initialize
    # this is an array of PaneLayouts,
    # and by default it has an unloaded
    # FilePane and a NotifPane
    @tabs = [PaneLayout.new(orientation=:vertical)]
    @tabs[0].add_pane FilePane.new, Curses::lines - 5
    @tabs[0].add_pane NotifPane.new, nil
  end

  def init_curses
    Curses::init_screen
    Curses::cbreak
    Curses::noecho
  end

  def deinit_curses
    Curses::nocbreak
    Curses::echo
    Curses::close_screen
  end
  
  def new_tab
    @tabs << PaneLayout.new
  end

  def draw
    Curses::setpos 0, 0
    Curses::addstr "Macronomicon v.0.0.0"
    Curses::setpos 1, 0
    Curses::addstr "Tabs: #{@tabs.length}"
    @tabs[0].draw [3,0], [Curses::lines - 1, Curses::cols - 1]
    Curses::refresh
  end

  def input
    ch = Curses::getch
    $KBD.each do |key, callback|
      # TODO: proper ctrl/alt handling
      # actually, doesn't curses handle it
      # automatically? i don't know yet
      if key === ch 
        callback[]
        return
      end
    end
    # Anything that isn't explicitly bound gets sent
    # through the #type_key function
    type_key ch.chr
  end

  def type_key(key)
    # TODO: method to track current tab and pane
    @tabs[0].type_key(key)
  end
end
