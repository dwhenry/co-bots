require 'spec_helper'

RSpec.describe DumbBot::Guess do
  subject { described_class.new(double(:details), double(:player_name)) }

  describe '#lower' do
    let(:color) { 'white' }

    context 'at the bottom' do
      let(:below_tiles) { [] }

      context 'when no tiles below this one' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower and higher tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 6], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([3, 4, 7, 8, 9, 10, 11])
        end
      end
    end

    context 'lower tiles of the same color - but no value - are below this one' do
      let(:below_tiles) { [{'color' => 'white'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower and higher tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 6], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 7, 8, 9, 10, 11])
        end
      end
    end

    context 'lower tiles of the same color - with value - are below this one' do
      let(:below_tiles) { [{'color' => 'white', 'value' => 3}, {'color' => 'white'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 5], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower and higher tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 9], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([6, 7, 8, 10, 11])
        end
      end

      context 'system bug' do
        let(:below_tiles) { [{'color' => 'white', 'value' => 0}] }
        let(:known_tiles) { { 'white' => [1, 2, 3, 5, 6, 9, 10, 11], 'black' => [1, 5, 7] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 7, 8, ])
        end
      end
    end

    context 'lower tiles of the opposite color - but no value - are below this one' do
      let(:below_tiles) { [{'color' => 'black'}, {'color' => 'black'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2], 'black' => [1, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([3, 4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower and higher tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 6], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([3, 4, 7, 8, 9, 10, 11])
        end
      end
    end

    context 'lower tiles of the opposite color - with value - are below this one' do
      let(:below_tiles) { [{'black' => 'white', 'value' => 3}, {'color' => 'black'}] }

      context 'when only higher tiles are known' do
        let(:known_tiles) { { 'white' => [], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 5, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower tiles are known' do
        let(:known_tiles) { { 'white' => [0, 5], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 6, 7, 8, 9, 10, 11])
        end
      end

      context 'when lower and higher tiles are known' do
        let(:known_tiles) { { 'white' => [0, 1, 2, 5, 9], 'black' => [5, 6] } }

        it 'returns list of tiles the are valid' do
          tile = subject.lower(known_tiles, below_tiles, color)
          expect(tile).to eq([4, 6, 7, 8, 10, 11])
        end
      end
    end
  end
end
