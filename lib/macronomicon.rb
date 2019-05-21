require "macronomicon/version"
require "macronomicon/editor"
require "curses"

module Macronomicon
  class Key
    attr_reader :key, :modifier
    def initialize(keystring)
      # key uses Emacs format
      # that is, C- for control and M- for alt
      @@valid_special_keys = Set.new %w[
        delete
        insert
        home
        end
        page-up
        page-down
        mouse-1
        mouse-2
        mouse-3
        f1
        f2
        f3
        f4
        f5
        f6
        f7
        f8
        f9
        f10
        f11
        f12
        escape
        tab
        caps-lock
        super
        return
      ]
      
      if keystring =~ /(C|M|)\-?([!-~])/
        @modifier = $1
        @key = $2
      elsif keystring =~ /(C\-|M\-)<(.+)>/
        if valid_special_keys.include? $2
          @modifier = $1
          @key = $2
        else
          throw "Invalid special key in #{keystring}"
        end
      else
        throw "Invalid keystring #{keystring}"
      end
    end

    def ===(keystring)
      # TODO: proper keystring matching
      @key == keystring
    end
  end
  
  class Error < StandardError; end
 
  ################################
  # BEGIN GLOBAL CONFIGURATION   #
  ################################
  $ED = Editor.new
  $KBD = {}
  (?!..?~).each do |typeable|
    $KBD[Key.new typeable] = -> { $ED.type_key typeable }
  end


  #####################
  # BEGIN MAIN LOOP   #
  #####################
  $ED.init_curses
  loop do 
    $ED.draw
    $ED.input
    sleep 0.01
  end
  $ED.deinit_curses
end











