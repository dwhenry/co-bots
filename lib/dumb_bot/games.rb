module DumbBot
  class Games
    TYPES = [:playing, :won, :lost, :waiting_for_players, :can_be_joined]
    attr_accessor *TYPES

    def initialize(api, data)
      @api = api
      self.playing = data["playing"]
      self.won = data["won"]
      self.lost = data["lost"]
      self.waiting_for_players = data["waiting_for_players"]
      self.can_be_joined = data["can_be_joined"]
    end

    def playing_in
      playing + waiting_for_players
    end

    TYPES.each do |type|
      define_method "#{type}_players" do
        @api.games_for(type).flat_map { |g| g['players'] }
      end
    end

    def player_count(player_name)
      @player_counts ||= begin
        array = playing_players + waiting_for_players_players
        grouped = array.group_by {|a| a}
        grouped.each_with_object({}) { |(k, v), h| h[k] = v.count }
      end

      @player_counts[player_name] || 0
    end

    def joinable_game(max_games_with_player)
      return nil if can_be_joined <= 0
      result = @api.games_for(:can_be_joined).detect do |game|
        game['players'].all? do |player|
          player_count(player) < max_games_with_player
        end
      end
      result ? result['uuid'] : nil
    end
  end
end
