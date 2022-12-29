require 'rails_helper'

describe FormatSseData do
  subject(:service) { described_class }

  let(:line_with_data)         { 'data: {"pin": {"id": 12}}' }
  let(:line_without_data)      { 'data: {}' }
  let(:line_with_invalid_data) { 'wrong_key_data: {}' }

  describe '.call' do
    context 'where there is existing data' do
      it 'returns the formated data' do
        expected_formated_data = {
          'id' => 12
        }
        expect(service.call(line_with_data)).to eq(expected_formated_data)
      end
    end

    context 'when there is no data' do
      it 'returns an empty object' do
        expected_formated_data = {  }

        expect(service.call(line_without_data)).to eq(expected_formated_data)
      end
    end

    context 'when the data key is wrong' do
      it 'returns an empty object' do
        expected_formated_data = {  }

        expect(service.call(line_with_invalid_data)).to eq(expected_formated_data)
      end
    end
  end
end
