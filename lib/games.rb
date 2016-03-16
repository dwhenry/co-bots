class Games
  def initialize(api, _config)
    @api = api
    @game_counts = @api.games
  end

  def playing_in
    @game_counts['playing'] + @game_counts['waiting_for_players']
  end

  def join
    return nil if @game_counts['can_be_joined'] <= 0
    uuid = @api.games_for(:can_be_joined).shuffle.first['uuid']
    @api.perform(uuid, :join)
  end

  def create(player_count=4)
    @api.create_game(player_count)
  end

  def with_actions
    @api.games_for(:playing).select do |game|
      @api.game(game['uuid'])['actions'].any?
    end
  end
end
