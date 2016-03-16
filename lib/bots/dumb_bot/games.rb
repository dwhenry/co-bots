module DumbBot
  class Games < ::Games
    def initialize(_api, config)
      @config = config
      super
    end

    def join
      joinable_game_uuid = joinable_game(@config['same_player'])
      joinable_game_uuid && @api.perform(joinable_game_uuid, :join)
    end

    def create(player_count=nil)
      super(player_count || @config['default_game_size'])
    end

    def with_actions
      [ super.first ].compact
    end

    private

    def opponent_names
      @api.games_for(:playing).flat_map { |g| g['players'] } +
      @api.games_for(:waiting_for_players).flat_map { |g| g['players'] }
    end

    def opposition_count
      @player_counts ||=
        opponent_names.each_with_object(Hash.new(0)) do |player_name, h|
          h[player_name] += 1
        end
    end

    def joinable_game(max_games_with_player)
      return nil if @game_counts['can_be_joined'] <= 0
      result = @api.games_for(:can_be_joined).detect do |game|
        game['players'].all? do |player|
          opposition_count[player] < max_games_with_player
        end
      end
      result ? result['uuid'] : nil
    end
  end
end
