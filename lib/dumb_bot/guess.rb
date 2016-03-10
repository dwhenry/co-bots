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

      pick = (best_picks || picks).shuffle.first
    end

    def picks_for_players(players, known_tiles)
      players.flat_map do |player|
        next if player['name'] == @player_name

        tiles = player['tiles']
        name = player['name']

        winners = tiles_for_player(known_tiles, name, tiles)
        if winners.count == 1
          return winners
        end
        winners
      end.compact
    end

    def tiles_for_player(known_tiles, name, tiles)
      tiles.each_with_index.flat_map do |tile, index|
        next if tile['value']
        # puts "Looking at: #{name}: #{index}"
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

    def best_picks(options)
      pick_counts = options.group_by { |o| [o[:player], o[:tile_position]] }.
        map { |k, a| [k, a.count] }

      min_count = pick_counts.map { |_, c| c}.min

      picks = pick_counts.select { |_, c| c == min_count }.map(&:first)

      if picks.count < 2
        options.select { |o| picks.include?([o[:player], o[:tile_position]]) }
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

    def higher(known_tiles, above_tiles, color)
      other_color = color == 'white' ? 'black' : 'white'
      color_tiles = (0..11).to_a - known_tiles[color]
      other_tiles = (0..11).to_a - known_tiles[other_color]

      above_tiles.reverse.each do |tile|
        # binding.pry if tile['value']
        if tile['color'] == color
          up(color_tiles, other_tiles, tile['value'])
        else
          up(other_tiles, color_tiles, tile['value'])
        end
      end
      color_tiles
    rescue => e
    end

    def up(alpha, beta, value)
      last = nil
      if value
        while alpha.any? && alpha[-1] >= value
          last = alpha.pop
        end
        last = [value, last].compact.min
      else
        last = alpha.pop
      end
      while beta.any? && beta[-1] > last
        beta.pop
      end
    end


    def lower(known_tiles, below_tiles, color)
      other_color = color == 'white' ? 'black' : 'white'
      color_tiles = (0..11).to_a - known_tiles[color]
      other_tiles = (0..11).to_a - known_tiles[other_color]

      below_tiles.each do |tile|
        if tile['color'] == color
          down(color_tiles, other_tiles, tile['value'])
        else
          down(other_tiles, color_tiles, tile['value'])
        end
      end
      color_tiles
    end

    def down(alpha, beta, value)
      last = nil
      if value
        while alpha.any? && alpha[0] <= value
          last = alpha.shift
        end
        last = [value, last].compact.max
      else
        last = alpha.shift
      end
      # binding.pry
      while beta.any? && beta[0] < last
        beta.shift
      end
    end
  end
end
