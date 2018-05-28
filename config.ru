require "roda"
require "json"
require "battlesnake"

HEADS = %w[bendr dead fang pixel regular safe sand-worm shades smile tongue]
TAILS = %w[block-bum curled fat-rattle freckled pixel regular round-bum skinny small-rattle]
COLOR = Proc.new{ "#%06x" % (rand * 0xffffff) }

$world = nil

class App < Roda
  route do |r|
    r.post "end" do
      p JSON.parse(request.body.read)
      {}.to_json
    end
    
    r.post "move" do
      a = JSON.parse(request.body.read)
      puts a.to_json
      $world = Battlesnake::World.new(id: a['id'], width: a['width'], height: a['height'])
      $world.update_food a.dig('food', 'data').to_a.map{|h| SnakePos[h['x']*-1, h['y']*-1]}
      $world.update_snakes a.dig('snakes', 'data')
      $world.update_snake a['you']
      a = $world.snake.move.to_s
      {move: a}.to_json
    end
    
    r.post "start" do
      a = JSON.parse(request.body.read)
      p a
      {
        color: COLOR.call,
        secondary_color: COLOR.call,
        head_url: "https://avatars1.githubusercontent.com/u/6775896?s=460&v=4",
        taunt: "My Snake v1",
        head_type: HEADS.sample,
        tail_type: TAILS.sample
      }.to_json
    end
  end
end

run App.freeze.app
