require 'spec_helper'

RSpec.describe DumbBot::Guess do
  subject { described_class.new(double(:details), double(:player_name)) }

  describe '#tiles_for_player' do
    context 'game example' do

      let(:name) { "jones4" }
      let(:tiles) do
        [
          {"color"=>"white"},
          {"color"=>"white"},
          {"color"=>"black"},
          {"color"=>"white"}
        ]
      end
      let(:known_tiles) do
        {
          "white" => [2, 4, 7],
          "black" => [1, 7]
        }
      end

      def picks_at(position)
        subject.tiles_for_player(known_tiles, name, tiles)
        .select { |p| p[:tile_position] == position }
      end

      context 'has known tiles at' do
        it 'position 0' do
          expect(picks_at(0)).to eq([
            {:player=>"jones4", :tile_position=>0, :value=>0, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>1, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>3, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>5, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>6, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>8, :color=>"white"},
            {:player=>"jones4", :tile_position=>0, :value=>9, :color=>"white"}
          ])
        end
      end
    end
  end
end
