module Battlesnake
  class Item
    attr_accessor :snake
    def initialize(type)
      @type = type
      @dead = %i[map_x map_y head body].include?(@type)
      @risky = %i[possible_next_head].include?(@type)
      @safe = %i[food].include?(@type)
    end

    def self.[](type); new(type); end

    def free?
      @type == :free
    end

    def dead?
      @dead
    end

    def risky?
      @risky
    end

    def safe?
      @safe
    end
    
    Types = %i[map_x map_y food head body possible_next_head].freeze
    List = Types.map{|x| [x, Item.new(x)]}.to_h.freeze
  end
end
