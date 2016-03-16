module DumbBot
  class Actions < ::Actions

    attr_accessor :engine

    def pick_tile
      _tile, index = engine['game']['tiles'].each_with_index.reject { |t, i| t['selected'] }.shuffle.first

      @api.perform(engine['uuid'], :pick_tile, tile_index: index)
    end

    def guess
      pick = Guess.new(engine, @player_name).guess
      @api.perform(engine['uuid'], :guess, pick )
    end
  end
end
