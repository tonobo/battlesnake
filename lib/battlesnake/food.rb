module Battlesnake
  class Food
    attr_reader :pos, :world

    def initialize(pos:, world:)
      @pos, @world = pos, world
    end
  end
end
