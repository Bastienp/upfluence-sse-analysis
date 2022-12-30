require 'rails_helper'
require 'duration_parser'

describe DurationParser do
  subject(:lib) { described_class }

  describe '.convert_to_seconds' do
    it 'returns duration converted in seconds' do
      aggregate_failures do
        expect(lib.convert_to_seconds('2s')).to  eq(2)
        expect(lib.convert_to_seconds('2m')).to  eq(120)
        expect(lib.convert_to_seconds('48h')).to eq(172800)
      end
    end

    it 'raises an error when the duration token is not recognised' do
      expect { lib.convert_to_seconds('2d') }.to raise_error(ArgumentError, 'unrecognised token')
    end
  end
end
