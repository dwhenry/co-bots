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
      # puts "*" * 20
      # puts @config['name']

      data = @api.games
      # puts data
      games = DumbBot::Games.new(@api, data)

      if games.playing_in < @config['max_games']
        if (joinable_game_uuid = games.joinable_game(@config['same_player']))
          # puts "joining #{joinable_game_uuid}"
          @api.perform(joinable_game_uuid, :join)
          true
        else
          # puts 'creating'
          @api.create_game(@config['default_game_size'])
          true
        end
      else
        false
      end
    end

    def take_next_game_action
      next_game = @api.games_for(:playing).detect do |game|
        @api.game(game['uuid'])['actions'].any?
      end

      if next_game
        next_game = @api.game(next_game['uuid'])
        DumbBot::Actions.new(@api, @config['name'], next_game).perform
      end
    end
  end
end
