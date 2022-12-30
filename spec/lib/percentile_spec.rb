require 'rails_helper'
require 'percentile'

describe Percentile do
  subject(:lib) { described_class.new }

  describe '.get' do
    before do
      lib.push(10)
      lib.push(2)
      lib.push(20)
      lib.push(40)
      lib.push(3)
    end

    it 'calculates the asked percentile' do
      aggregate_failures do
        expect(lib.calculate(0.1)).to eq(2)
        expect(lib.calculate(0.5)).to eq(10)
        expect(lib.calculate(0.9)).to eq(40)
      end

    end

    it 'raise an error if the asked percentile is not supported' do
      aggregate_failures do
        expect { lib.calculate(-0.5) }.to raise_error(ArgumentError, 'percentile should be between 0 excluded and 1 excluded')
        expect { lib.calculate(0) }.to    raise_error(ArgumentError, 'percentile should be between 0 excluded and 1 excluded')
        expect { lib.calculate(1) }.to    raise_error(ArgumentError, 'percentile should be between 0 excluded and 1 excluded')
        expect { lib.calculate(1.5) }.to  raise_error(ArgumentError, 'percentile should be between 0 excluded and 1 excluded')
      end
    end
  end
end
