module DumbBot
  class Guess
    attr_reader :details
    def initialize(details, player_name)
      @details = details
      @player_name = player_name
    end

    def guess
      picks =  picks_for_players(details['game']['players'], tiles_by_color)

      delete = [5,6,4,7,3,8,2,9,1,10,0,11]
      pruned_picks = picks.dup

      best_picks = picks if picks.count == 1
      until pruned_picks.empty? || (best_picks ||= best_picks(pruned_picks))
        delete_value = delete.shift
        pruned_picks = pruned_picks.reject { |o| o[:value] == delete_value}
      end

      (best_picks || picks).shuffle.first
    end

    def picks_for_players(players, known_tiles)
      players.flat_map do |player|
        next if player['name'] == @player_name

        player_tiles = tiles_for_player(known_tiles, player['name'], player['tiles'])
        return player_tiles if player_tiles.count == 1
        player_tiles
      end.compact
    end

    def tiles_for_player(known_tiles, name, tiles)
      tiles.each_with_index.flat_map do |tile, index|
        next if tile['value']

        options = lower(known_tiles, index == 0 ? [] : tiles[0..index-1], tile['color']) &
          higher(known_tiles, tiles[index+1..-1], tile['color'])

        options.map do |value|
          {
            player: name,
            tile_position: index,
            value: value,
            color: tile['color']
          }
        end
      end
    end

    def best_picks(options, group_field=:tile_position, min_count_win=1)
      pick_counts = options.group_by { |o| [o[:player], o[group_field]] }

      min_count = pick_counts.map { |_, c| c.count }.min

      picks = pick_counts.select { |_, c| c.count == min_count }

      if picks.count < 2 || min_count <= min_count_win
        picks.flat_map(&:last)
      else
        nil
      end
    end

    def tiles_by_color
      tiles = details['game']['players'].flat_map do |player|
        player['tiles'].select { |t| t['value'] }
      end

      tiles.
        sort_by { |t| t['value'] }.
        group_by { |t| t['color'] }.
        each_with_object(Hash.new { |h, k| h[k] = []}) { |(c, a), h| h[c] = a.map { |t| t['value'] } }
    end

    def possible_tiles(known_tiles, hand, color, direction)
      other_color = color == 'white' ? 'black' : 'white'
      color_tiles = (0..11).to_a - known_tiles[color]
      other_tiles = (0..11).to_a - known_tiles[other_color]

      hand.each do |tile|
        if tile['color'] == color
          send(direction, color_tiles, other_tiles, tile['value'])
        else
          send(direction, other_tiles, color_tiles, tile['value'])
        end
      end
      color_tiles
    end

    def higher(known_tiles, above_tiles, color)
      possible_tiles(known_tiles, above_tiles.reverse, color, :up)
    end

    def lower(known_tiles, below_tiles, color)
      possible_tiles(known_tiles, below_tiles, color, :down)
    end


    def up(alpha, beta, value)
      last = nil
      if value
        while alpha.any? && alpha[-1] >= value
          last = alpha.pop
        end
        last = [value, last].compact.min # deal with no value in list
      else
        last = alpha.pop
      end
      while beta.any? && beta[-1] > last
        beta.pop
      end
    end

    def down(alpha, beta, value)
      last = nil
      if value
        while alpha.any? && alpha[0] <= value
          last = alpha.shift
        end
        last = [value, last].compact.max # deal with no value in list
      else
        last = alpha.shift
      end
      while beta.any? && beta[0] < last
        beta.shift
      end
    end
  end
end
