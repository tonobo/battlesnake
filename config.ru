require "roda"
require "json"
require "battlesnake"
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'ruby-prof'

HEADS = %w[bendr dead fang pixel regular safe sand-worm shades smile tongue]
TAILS = %w[block-bum curled fat-rattle freckled pixel regular round-bum skinny small-rattle]
COLOR = Proc.new{ "#%06x" % (rand * 0xffffff) }
MOVES = %i[up down right left]

use Rack::Deflater
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

RUBY_PROF = ENV.fetch("ENABLE_PROF", false)

class App < Roda
  route do |r|
    r.post "end" do
      p JSON.parse(request.body.read)
      {}.to_json
    end
    
    r.post "move" do
      a = request.body.read
      puts a
      a = JSON.parse(a)
      RubyProf.start if RUBY_PROF
      world = Battlesnake::World.new(
        options: { deadlock: { limit: 10, retry: 3 } }
      )
      world.update(a)
      a = world.snake.move.to_s
      if RUBY_PROF
        result = RubyProf.stop 
        printer = RubyProf::FlatPrinter.new(result)
        printer.print(STDOUT)
      end
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
