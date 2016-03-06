module DumbBot
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
