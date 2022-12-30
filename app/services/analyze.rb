require 'upfluence/sse/listen'
require 'duration_parser'
require 'percentile'

class Analyze
  private

  attr_reader :duration_seconds, :dimension, :maximum_timestamp,
              :minimum_timestamp, :number_of_posts, :percentile,
              :upfluence_sse_stream

  public

  def self.call(duration, dimension)
    new(duration, dimension).call
  end

  def initialize(duration, dimension)
    @duration_seconds     = DurationParser.convert_to_seconds(duration)
    @dimension            = dimension
    @number_of_posts      = 0
    @minimum_timestamp    = Float::INFINITY
    @maximum_timestamp    = -Float::INFINITY
    @percentile           = Percentile.new
    @upfluence_sse_stream = Upfluence::Sse::Listen.instance

    subscribe_to_sse_stream
  end

  def call
    sleep(duration_seconds)

    unsubscribe_from_sse_stream

    payload
  end

  def update(data)
    json_formatted_data = ::FormatSseData.call(data)

    if json_formatted_data.any?
      @number_of_posts += 1
      @minimum_timestamp = [@minimum_timestamp, json_formatted_data['timestamp']].min
      @maximum_timestamp = [@maximum_timestamp, json_formatted_data['timestamp']].max
      percentile.push(json_formatted_data[dimension] || 0)
    end
  end

  private

  def subscribe_to_sse_stream
    upfluence_sse_stream.add_observer(self)
  end

  def unsubscribe_from_sse_stream
    upfluence_sse_stream.delete_observer(self)
  end

  def payload
    {
      "total_posts"       => number_of_posts,
      "minimum_timestamp" => minimum_timestamp,
      "maximum_timestamp" => maximum_timestamp,
      "#{dimension}_p50"  => percentile.calculate(0.5),
      "#{dimension}_p90"  => percentile.calculate(0.9),
      "#{dimension}_p99"  => percentile.calculate(0.99)
    }
  end
end
