require 'rails_helper'

describe Analyze do
  subject(:service) { described_class }

  describe '.call' do
    before do
      allow_any_instance_of(Analyze).to receive(:sleep)
    end

    it 'calls DurationParser with duration' do
      expect(DurationParser).to receive(:convert_to_seconds).with('2h')

      service.call('2h', 'likes')
    end

    it 'calls Upfluence::Sse::Listen instance and add an observer' do
      allow(Upfluence::Sse::Listen.instance).to receive(:add_observer)
      allow(Upfluence::Sse::Listen.instance).to receive(:delete_observer)

      expect(Upfluence::Sse::Listen).to receive(:instance).and_return(Upfluence::Sse::Listen.instance)

      service.call('2h', 'likes')
    end

    it 'adds itself as an observer of Upfluence::Sse::Listen instance' do
      allow(Upfluence::Sse::Listen).to receive(:instance).and_return(Upfluence::Sse::Listen.instance)
      allow(Upfluence::Sse::Listen.instance).to receive(:delete_observer)

      expect(Upfluence::Sse::Listen.instance).to receive(:add_observer).with(service)

      service.call('2h', 'likes')
    end

    it 'deletes itself Upfluence::Sse::Listen instance observers' do
      allow(Upfluence::Sse::Listen).to receive(:instance).and_return(Upfluence::Sse::Listen.instance)
      allow(Upfluence::Sse::Listen.instance).to receive(:add_observer)

      expect(Upfluence::Sse::Listen.instance).to receive(:delete_observer).with(service)

      service.call('2h', 'likes')
    end

    it 'returns statistics analyzed' do
      analyze = Analyze.new('2s', 'retweets')

      # simulate that there is data returned by Sse Stream
      analyze.update('data: {"pin": {"id": 11, "timestamp": 1659476144, "retweets": 1}}')
      analyze.update('data: {"pin": {"id": 12, "timestamp": 1659476145, "retweets": 12}}')
      analyze.update('data: {"pin": {"id": 13, "timestamp": 1659476146, "retweets": 50}}')
      analyze.update('data: {"youtube_video": {"id": 1, "timestamp": 1659476146, "likes": 11}}')
      analyze.update('data: {"youtube_video": {"id": 2, "timestamp": 1659476147, "likes": 11}}')
      analyze.update('data: {"youtube_video": {"id": 3, "timestamp": 1659476148, "likes": 11}}')
      analyze.update('data: {"youtube_video": {"id": 4, "timestamp": 1659476149, "likes": 11}}')
      analyze.update('data: {"youtube_video": {"id": 5, "timestamp": 1659476150, "likes": 11}}')

      expected_payload = {
        'total_posts'       => 8,
        'maximum_timestamp' => 1659476150,
        'minimum_timestamp' => 1659476144,
        'retweets_p50'      => 0,
        'retweets_p90'      => 50,
        'retweets_p99'      => 50
      }
      expect(analyze.call).to eq(expected_payload)
    end
  end

  describe '.udpate' do
    before do
      allow_any_instance_of(Analyze).to receive(:sleep)
    end

    it 'calls FormatSseData with data' do
      observer = service.new('1s', 'likes')

      expect(FormatSseData).to receive(:call).with('data: {"pin": {"id": 12, "timestamp": 1659476145}}').and_return('id' => 12, 'timestamp' => 1659476145)

      observer.update('data: {"pin": {"id": 12, "timestamp": 1659476145}}')
    end

    it 'calls Percentile push method with dimension value' do
      observer = service.new('1s', 'likes')

      allow(FormatSseData).to receive(:call).with('data: {"pin": {"id": 12, "timestamp": 1659476145, "likes": 12}}').and_return('id' => 12, 'timestamp' => 1659476145, 'likes' => 12)

      expect_any_instance_of(Percentile).to receive(:push).with(12)

      observer.update('data: {"pin": {"id": 12, "timestamp": 1659476145, "likes": 12}}')
    end

    it 'calls Percentile push method with 0 if dimension does not exist' do
      observer = service.new('1s', 'likes')

      allow(FormatSseData).to receive(:call).with('data: {"pin": {"id": 12, "timestamp": 1659476145, "retweets": 12}}').and_return('id' => 12, 'timestamp' => 1659476145, 'retweets' => 12)

      expect_any_instance_of(Percentile).to receive(:push).with(0)

      observer.update('data: {"pin": {"id": 12, "timestamp": 1659476145, "retweets": 12}}')
    end
  end
end
