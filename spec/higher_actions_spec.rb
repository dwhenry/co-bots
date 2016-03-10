require 'spec_helper'

RSpec.describe DumbBot::Guess do
  subject { described_class.new(double(:details), double(:player_name)) }

  describe '#higher' do
    let(:color) { 'white' }

    context 'at the top' do
      let(:above_tiles) { [] }

      context 'when no tiles below this one' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [9, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([3, 4, 5, 6, 7, 8, 9])
        end
      end
    end

    context 'higher tiles of the same color - but no value - are below this one' do
      let(:above_tiles) { [{'color' => 'white'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [9, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 9, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([3, 4, 5, 6, 7, 8])
        end
      end
    end

    context 'higher tiles of the same color - with value - are below this one' do
      let(:above_tiles) { [{'color' => 'white'}, {'color' => 'white', 'value' => 9}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [8, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 8], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([3, 4, 6])
        end
      end
    end

    context 'higher tiles of the opposite color - but no value - are below this one' do
      let(:above_tiles) { [{'color' => 'black'}, {'color' => 'black'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [9, 10, 11], 'black' => [1, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [5, 6, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 7, 8, 9])
        end
      end
    end

    context 'higher tiles of the opposite color - with value - are below this one' do
      let(:above_tiles) { [{'color' => 'black'}, {'black' => 'white', 'value' => 9}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [5, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 6, 7, 8])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [5, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 6, 7, 8])
        end
      end

      context 'system bug' do
        let(:below_tiles) { [{'color' => 'white', 'value' => 11}] }
        let(:known_tiles) { { 'white' => [0, 7, 11], 'black' => [] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, below_tiles, color)
          expect(tile).to eq([1, 2, 3, 4, 5, 6, 8, 9, 10])
        end
      end

      context 'system bug 2' do
        let(:below_tiles) do
          [
            {"color"=>"black", "value"=>3},
            {"color"=>"black"},
            {"color"=>"white"},
            {"color"=>"black"},
            {"color"=>"white"},
            {"color"=>"black"}
          ]
        end
        let(:known_tiles) { {"black"=>[0, 1, 2, 3, 8, 9], "white"=>[2, 3, 5, 9, 11]} }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, below_tiles, color)
          expect(tile).to eq([0, 1])
        end
      end

    end

    context 'when one of players tiles is already known' do
      let(:above_tiles) { [{'color' => 'white'}, {'black' => 'white', 'value' => 8}, {'black' => 'white', 'value' => 9}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [8, 9], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6])
        end
      end

      context 'when higher tiles are known' do
        let(:known_tiles) { { 'white' => [5, 8, 9, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 6])
        end
      end

      context 'when higher and lower tiles are known' do
        let(:known_tiles) { { 'white' => [5, 8, 9, 10, 11], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.higher(known_tiles, above_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 6])
        end
      end
    end
  end
end
