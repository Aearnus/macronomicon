require "curses"

class FilePane
  def initialize
    @current_file = nil
    @scroll_line = 0
  end

  def draw(top_left, bottom_right)
  end

  def load_file(filename)
  end
end

class NotifPane
  def initialize
    @current_notif = "Hello, world!"
  end

  def draw(top_left, bottom_right)
  end

  def send_notif(text)
  end
end

class PaneLayout
  attr_accessor :layout
  def initialize(top_left, bottom_right, orientation=:horizontal)
    @top_left = top_left
    @bottom_right = bottom_right

    # this is an n-tuple containing both sides of the editor
    # either top & bottom or left & right.
    # each element is either a *Pane or another PaneLayout.
    # it doesn't actually matter though -- they both have
    # the same #draw prototypical method
    @layout = []
  end

  def draw(top_left, bottom_right)
  end

  def new_file_pane
    @layout << FilePane.new
    @layout.last
  end
end



class Editor
  attr_accessor :tabs
  def initialize
    # this is an array of PaneLayouts,
    # and by default it has an unloaded
    # FilePane and a NotifPane
    @tabs = [PaneLayout.new([0, 0], [rows, cols], orientation=:vertical)]
    @tabs[0].new_file_pane
    @tabs[0].layout << NotifPane.new
  end

  def init_curses
    Curses::init_screen
    Curses::cbreak
  end

  def deinit_curses
    Curses::nocbreak
    Curses::close_screen
  end
  
  def new_tab
    @tabs << PaneLayout.new
  end

  def draw

  end

  def input
    ch = Curses::getch

    
  end
end
