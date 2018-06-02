module Battlesnake
  class World
    attr_accessor :id, :width, :height
    attr_reader :snake, :foods, :snakes, :options

    def initialize(options: {})
      @options = options
    end

    def vmap
      @vmap ||= begin
                  (0..(height-1)).to_a.map do |y|
                    (0..(width-1)).to_a.map do |x|
                      s = Battlesnake::Pos[y,x]
                      s.world = self
                      s
                    end
                  end
                end
    end

    def v(y,x)
      return if y < 0 || x < 0
      vmap[y]&.fetch(x, nil)
    end

    def render
      print '   '
      vmap[0].each.with_index{|_v,i| printf "%#3d", i }
       vmap.map.with_index do |x,i| 
         puts
         printf "%#3d", i
         x.each{|y| print ' '+y.render+' '}
         printf "%#3d", i
       end
       puts
      print '   '
      vmap[0].each.with_index{|_v,i| printf "%#3d", i }
       puts
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

    def update(a)
      update_world(a)
      update_food a.dig('food', 'data')
      update_snake a['you']
      update_snakes a.dig('snakes', 'data')
    end

    def update_world(a)
      self.id = a['id'], 
      self.width = a['width'], 
      self.height = a['height']
    end

    def update_food(points)
      @foods = []
      points.map do |h| 
        x = v(h['y'], h['x'])
        x.item = Item[:food]
        @foods << x
      end
    end

    def update_snake(h)
      points = h.dig('body', 'data').map do |point|
        v(point['y'], point['x'])
      end
      @snake = Snake.new(id: h['id'], health: h['health'], world: self, points: points)
    end
    
    def update_snakes(snakes)
      @snakes = snakes.map do |h|
        next if snake.id == h['id']
        points = h.dig('body', 'data').map do |point|
          v(point['y'], point['x'])
        end
        Snake.new(id: h['id'], health: h['health'], world: self, points: points)
      end.compact
    end

  end
end
