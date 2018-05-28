require "battlesnake/version"
require "matrix"
require "json"
require "battlesnake/snake"
require "battlesnake/world"
require "battlesnake/food"

class SnakePos < Vector
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

  def move(direction)
    case direction
    when :up then SnakePos[self[0], self[1] + 1]
    when :down then SnakePos[self[0], self[1] - 1]
    when :right then SnakePos[self[0] - 1, self[1]]
    when :left then SnakePos[self[0] + 1, self[1]]
    end
  end

  def around
    %i[up down left right].map{|x| move(x)}
  end

  def direction
    VECTOR_TO_DIRECTION[map{ |val| val / val.abs rescue 0 }]
  end
end

module Battlesnake
end
