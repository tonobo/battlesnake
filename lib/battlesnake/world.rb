module Battlesnake
  class World
    attr_reader :id, :width, :height, :foods, :snakes, :snake

    def initialize(id:, width:, height:)
      @id, @width, @height = id, width, height
    end

    def blocked(pos, ignore: nil)
      return :map_x unless pos[0].between?((width+-1)*-1, 0)
      return :map_y unless pos[1].between?((height+-1)*-1, 0) 
      snakes.to_a.each do |s|
        b = s.blocked(pos, ignore: ignore)
        return b if b
      end
      foods.to_a.each do |f|
        return :food if f.pos == pos
      end
      return
    end

    def enemies
      snakes.reject{|s| s.id == snake.id }
    end

    def killable_enemies
      enemies.select{|s| s.size < snake.size }
    end

    def targets
      foods.to_a + killable_enemies
    end

    def update_food(points)
      @foods = points.map do |point|
        Food.new(pos: point, world: self)
      end
    end

    def update_snake(h)
      points = h.dig('body', 'data').map do |point|
        SnakePos[point['x']*-1, point['y']*-1]
      end
      s = Snake.new(id: h['id'], health: h['health'], world: self, points: points)
      if @snake.nil?
        @snake = s
        return
      end
      @snake.update(health: s.health, points: s.points)
    end
    
    def update_snakes(snakes)
      new_snakes = snakes.map do |h|
        points = h.dig('body', 'data').map do |point|
          SnakePos[point['x']*-1, point['y']*-1]
        end
        Snake.new(id: h['id'], health: h['health'], world: self, points: points)
      end
      if @snakes.nil?
        @snakes = new_snakes
        return
      end
      @snakes.keep_if do |snake|
        new_snakes.find{|x| x.id == snake.id }
      end
      @snakes.each do |snake|
        s = new_snakes.find{|x| x.id == snake.id }
        next if s.nil?
        snake.update(health: s.health, points: s.points)
      end
    end

  end
end
