class Actions
  EXECUTION_ORDER = [
    'finalize_hand',
    'pick_tile',
    'guess'
  ]

  attr_accessor :engine

  def initialize(api:, player_name:, uuid:)
    @api = api
    @player_name = player_name
    self.engine = @api.game(uuid)
  end

  def perform
    action_to_perform = self.class::EXECUTION_ORDER.detect do |action|
      engine['actions'].include?(action) && respond_to?(action)
    end || raise("Unknown actions: #{engine['actions']}")
    send(action_to_perform)
  end

  def finalize_hand
    @api.perform(engine['uuid'], :finalize_hand)
  end

  def pick_tile
    _tile, index = engine['game']['tiles'].each_with_index.reject { |t, i| t['selected'] }.shuffle.first

    @api.perform(engine['uuid'], :pick_tile, tile_index: index)
  end

  def guess
    # randomly pick a player, the a tile and then a value for tile.
    player = engine['game']['players'].shuffle.first
    tile, position = *player['tiles'].each_with_index.shuffle.first
    pick = {
      player: player['name'],
      tile_position: position,
      value: (0..11).to_a.shuffle.first,
      color: tile['color']
    }
    @api.perform(engine['uuid'], :guess, pick )
  end
end
