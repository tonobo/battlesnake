module Battlesnake
  class Snake
    attr_reader :id, :points, :points_before, :world, :health

    def initialize(id:, points:, world:, health:)
      @id, @points, @world = id, points, world
      @health = health
      fill_vmap
    end

    def fill_vmap
      points[0..-2].each.with_index do |x,i|
        next x.item = Battlesnake::Item[:head] if i.zero?
        next if x.nil?
        x.item = Battlesnake::Item[:body]
        x.item.snake = self
      end
      return if world.snake.nil?
      if me?
        head.around.each do |x|
          next if x.nil?
          x.item = Battlesnake::Item[:possible_next_head]
          x.item.snake = self
        end
      end
    end

    def me?
      id != world.snake.id
    end

    def head
      @head ||= points.first
    end

    def walk(to:)
      Route.new(from: head, to: to.dup, world: world)
    end

    def food_routes
      @food_routes ||= world.foods.map do |f|
        walk(to: f)
      end
    end

    def preferred_route
      foods = food_routes
      dead = []
      world.options[:deadlock].to_h.fetch(:retry, 3).times do
        foods.each do |route|
          if route.resolved? && route.deadlock?(targets: foods)
            dead << route
            route.dead!(route) 
          end
        end
      end
      a = foods.select(&:resolved?).reject(&:risky?).min_by(&:steps) ||
        foods.select(&:resolved?).min_by(&:steps)
      return a if a
      foods.each do |route|
        dead.map{|x| route.dead!(x) }
        route.moves
      end
      foods.select(&:resolved?).reject(&:risky?).min_by(&:steps) ||
        foods.select(&:resolved?).min_by(&:steps)
        foods.max_by(&:steps)
    end

    def move
      preferred_route&.turn || 'unkown'
    end

    def size
      points.size
    end
  end
end
