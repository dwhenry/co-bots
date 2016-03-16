$LOAD_PATH << './lib/bots'

require 'net/http'
require 'pry'

require 'simple_api'
require 'games'
require 'actions'

require 'bots/dumb_bot'

class Bot
  def initialize(domain, config)
    @config = config
    @api = SimpleApi.new(
      name: config['name'],
      password: config['password'],
      domain: domain
    )
    klass_name = config['class'] || 'DumbBot'
    require_name = klass_name.gsub(/(.?[A-Z])/) do |w|
      if w[-2]
        w[-2] + '_' + w[-1].downcase
      else
        w[-1].downcase
      end
    end
    require require_name
    @bot_klass = Kernel.const_get(klass_name)
  end

  def take_next_action
    join_game || take_next_game_action
  end

  def join_game
    games = @bot_klass::Games.new(@api, @config)

    if games.playing_in < @config['max_games']
      games.join || games.create
    end
  end

  def take_next_game_action
    games = @bot_klass::Games.new(@api, @config)
    games.with_actions.each do |game_json|
      @bot_klass::Actions.new(
        api: @api,
        player_name: @config['name'],
        uuid: game_json['uuid']
      ).perform
    end
  end
end
