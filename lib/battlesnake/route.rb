module Battlesnake
  class Route
    attr_reader :world, :from, :to, :limit

    def initialize(world:, from:, to:, limit: nil)
      @world, @from, @to, @limit = world, from, to, limit
      moves
    end
    
    alias soure from
    alias destination to

    def resolved?
      !@resolved.nil?
    end

    def risky?
      moves.first&.fetch(0, nil)&.item.risky?
    end
    
    def safe?
      !risky?
    end

    def turn
      moves.first&.fetch(1, "unknown")
    end

    def stopped?
      !@stopped.nil?
    end

    def steps
      @steps ||= moves.size
    end

    def deadlock?(targets:)
      moves # ensure moves already calculated
      deadlock_limit = world.options.dig(:deadlock, :limit)
      return false if deadlock_limit.nil?
      t = targets.reject{|x| x.destination == self.destination }
      return false if t.none?
      t.each do |x|
        route = self.class.new(world: world, from: destination, 
                               to: x.destination, limit: deadlock_limit)
        if route.moves.none?
          @resolved = nil
          return true
        end
        return false if route.resolved?
        return false if route.stopped?
      end
      @resolved = nil
      true
    end

    def dead!(route)
      clear
      dead_points.push(*route.moves.map(&:first))
    end

    def dead_points
      @dead_points ||= []
    end

    def moves(flush: false)
      clear if flush
      @moves ||= _moves
    end

    def clear
      @resolved = nil
      @stopped = nil
      @moves = nil
      @steps = nil
    end

    private

    def _moves
      steps = []
      pos = from
      step = 0
      until (pos - to).magnitude.zero?
        step += 1
        a = MOVES.sort_by do |x| 
          pm = pos.move(x)
          next Float::INFINITY if pm.nil?
          (pm - to).magnitude 
        end.find do |move|
          if step == limit
            @stopped = true
            return steps 
          end
          np = pos.move(move)
          next if dead_points.include?(np)
          next if np.nil?
          next if np.item.dead?
          next if steps.any?{|x| x[0] == np }
          steps << [np, move]
          pos = np
        end
        return steps if a.nil?
      end
      @resolved = true
      steps
    end
  end
end
