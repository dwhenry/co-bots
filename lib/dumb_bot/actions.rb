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
      pick = Guess.new(details, @player_name).guess
      @api.perform(details['uuid'], :guess, pick )
    end
  end
end
