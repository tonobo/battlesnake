module Battlesnake
  class Pos < Vector
    VECTOR_TO_DIRECTION = {
      Vector[ 1,  0] => :right,
      Vector[ 1,  1] => :down, # SE
      Vector[ 0,  1] => :down,
      Vector[-1,  1] => :down, # SW
      Vector[-1,  0] => :left,
      Vector[-1, -1] => :up, # NW
      Vector[ 0, -1] => :up,
      Vector[ 1, -1] => :up # NE
    }.freeze

    attr_accessor :world

    def item
      @item || Item[:free]
    end

    def item=(i)
      case
      when item.dead?, item.risky? then return
      else @item = i
      end
    end

    def render
      case
      when item.free? then "."
      when item.dead?
        return "\033[1m\033[31m+\033[0m" if world.snakes.map(&:head).include? self
        return "\033[31m+\033[0m" if world.snakes.flat_map(&:points).include? self
        return "\033[1m\033[33m+\033[0m" if world.snake.head == self
        return "\033[1m+\033[0m" if world.snake.points.include? self
        "+"
      when item.risky? then "?"
      when item.safe? then "o"
      end
    end

    def move(direction)
      case direction
      when :right then world.v(self[0], self[1] + 1)
      when :left then world.v(self[0], self[1] - 1)
      when :up then world.v(self[0] - 1, self[1])
      when :down then world.v(self[0] + 1, self[1])
      end
    end

    def around
      MOVES.map{|x| move(x)}
    end

    def direction
      VECTOR_TO_DIRECTION[map{ |val| val / val.abs rescue 0 }]
    end
  end
end
