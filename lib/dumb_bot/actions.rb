module DumbBot
  class Actions
    EXECUTION_LIST = ['finalize_hand', 'pick_tile', 'guess']
    # move_tile

    attr_accessor :details

    def initialize(api, player_name, details)
      @api = api
      @player_name = player_name
      self.details = details
    end

    def perform
      action_to_perform = EXECUTION_LIST.detect { |action| details['actions'].include?(action) }
      action_to_perform || raise("Unknown actions: #{details['actions']}")
      send(action_to_perform)
    end

    def finalize_hand
      @api.perform(details['uuid'], :finalize_hand)
    end

    def pick_tile
      _tile, index = details['game']['tiles'].each_with_index.reject { |t, i| t['selected'] }.shuffle.first

      @api.perform(details['uuid'], :pick_tile, tile_index: index)
    end

    def guess
      tiles = details['game']['players'].flat_map do |player|
        player['tiles'].select { |t| t['value'] }
      end
      known_tiles = tiles.
        sort_by { |t| t['value'] }.
        group_by { |t| t['color'] }.
        each_with_object({}) { |(c, a), h| h[c] = a.map { |t| t['value'] } }

      picks = details['game']['players'].flat_map do |player|
        next if player['name'] == @player_name
        player['tiles'].each_with_index.flat_map do |tile, index|
          options = (0..11).to_a - known_tiles[tile['color']]
          # this does not take into account the other color
          lower = index
          upper = options.count - player['tiles'].count + index

          options[lower..upper].map do |value|
            {
              player: player['name'],
              tile_position: index,
              value: value,
              color: tile['color']
            }
          end
        end
      end

      binding.pry
      picks
    end
  end
end
