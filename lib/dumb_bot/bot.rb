module DumbBot
  class Bot
    # DOMAIN = 'simple-co-engine-api.herokuapp.com'
    DOMAIN = 'http://localhost:3002/'

    def initialize(config)
      @config = config
      @api = DumbBot::SimpleApi.new(name: config['name'], password: config['password'])
    end

    def take_next_action
      join_game || take_next_game_action
    end

    def join_game
      puts "*" * 20
      puts @config['name']

      data = @api.games
      puts data
      games = DumbBot::Games.new(@api, data)

      if games.playing_in < @config['max_games']
        if (joinable_game_uuid = games.joinable_game(@config['same_player']))
          puts "joining #{joinable_game_uuid}"
          @api.perform(joinable_game_uuid, :join)
          true
        else
          puts 'creating'
          @api.create_game(@config[:default_game_size])
          true
        end
      else
        false
      end
    end

    def take_next_game_action
      puts @api.games_for(:playing)
      next_game = nil
      has_action = @api.games_for(:playing).any? do |game|
        next_game = @api.game(game['uuid'])
        next_game['actions'].any?
      end

      DumbBot::Actions.new(@api, next_game).perform if has_action
    end
  end

  class Actions
    EXECUTION_LIST = ['pick_tile']

    attr_accessor :details

    def initialize(api, details)
      @api = api
      self.details = details
    end

    def perform
      action_to_perform = EXECUTION_LIST.detect { |action| details['actions'].include?(action) }

      send(action_to_perform)
    end

    def pick_tile
      _tile, index = details['game']['tiles'].each_with_index.reject { |t, i| t['selected'] }.shuffle.first

      @api.perform(details['uuid'], :pick_tile, tile_index: index)
    end
  end
end
