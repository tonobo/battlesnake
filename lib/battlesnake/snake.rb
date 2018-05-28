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
      (points_before.first - points.first).direction
    end

    def valid_moves(last_move: self.last_move)
      %i[up down left right]
    end

    def blocked(pos, ignore: nil)
      points[0..-2].each.with_index do |x,i|
        return :head if i.zero? && pos == x 
        return :body if pos == x
      end
      unless [ignore].include?(:possible_next_head)
        return :possible_next_head if id != world.snake.id && head.around.include?(pos) 
      end
      return
    end

    def head
      points.first
    end

    def walk(to:, ignore: nil)
      possibilities = []
      snake_head = head
      valid_moves.each do |move|
        moves = [move]
        pos = snake_head.move(move)
        next if pos != to && world.blocked(pos, ignore: ignore)
        points = [pos]
        until (pos - to).magnitude.zero?
          ret = valid_moves(last_move: moves.last).map do |m|
            a = [m, pos.move(m)]
            points << a[1]
            a << (a[1]- to).magnitude
          end
          ret.sort_by!{|x| x[2]}
          unless ret.first[1] == to
            ret.delete_if do |x|
              world.blocked(x[1], ignore: ignore) || points.count(x[1]) > 1
            end
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

    def move(ignore: nil)
      targets = world.targets.map do |f|
        case f
        when Food 
          walk(to: f.pos, ignore: ignore)
        end
      end.compact.flatten(1)
      x = targets.reject{|x| x.last == :unresolved }
      a = nil
      if x.empty?
        a = p(targets.sort_by{|f| f.size}.reverse)
      else
        a = p(x.sort_by{|f| f.size})
      end
      if a.empty? and ignore.nil?
        return        move(ignore: :possible_next_head)
      end
      a.find{|x| b = world.blocked(head.move(x[0])); b.nil? || b == :food }&.first || a[0][0]
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
