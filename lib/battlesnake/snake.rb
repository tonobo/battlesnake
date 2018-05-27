module Battlesnake
  class Snake
    attr_reader :id, :points, :points_before, :world, :health

    def initialize(id:, points:, world:, health:)
      @id, @points, @world = id, points, world
      @health = health
    end

    def last_move
      if points_before.nil?
        return %i[up down left right].sample
      end
      p (points_before.first - points.first).direction
    end

    def valid_moves(last_move: self.last_move)
      case l = last_move
      when :up, :down then [l, :left, :right]
      when :left, :right then [l, :up, :down]
      end
    end

    def blocked(pos)
      points.each.with_index do |x,i|
        return :head if i.zero? && pos == x 
        return :body if pos == x
      end
      return
    end

    def head
      points.first
    end

    def walk(to:)
      possibilities = []
      snake_head = head
      valid_moves.each do |move|
        moves = [move]
        pos = snake_head.move(move)
        points = [pos]
        until (pos - to).magnitude == 0
          ret = valid_moves(last_move: moves.last).map do |m| 
            a = [m, pos.move(m)]
            points << a[1]
            a << (a[1]- to).magnitude
          end
          ret.sort_by!{|x| x[2]}
          ret.delete_if do |x|
            world.blocked(x[1]) || points.count(x[1]) > 1
          end
          if ret.first.nil?
            moves << :unresolved
            possibilities << moves
            break
          end
          moves << ret.first[0]
          pos = ret.first[1]
        end
        possibilities << moves if pos == to
      end
      possibilities
    end

    def move
      targets = world.targets.map do |f|
        case f
        when Food then walk(to: f.pos)
        end
      end
      p head
      p targets.flatten(1).sort_by{|f| f.size}[0][0]
    end

    def update(health:, points:)
      @health = health
      @points_before = @points.dup
      @points = points
    end

    def size
      points.size
    end
  end
end
