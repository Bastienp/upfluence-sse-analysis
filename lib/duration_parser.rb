class DurationParser
  private

  TOKEN_TO_SECOND_MULTIPLIER = {
    's' => 1,
    'm' => 60,
    'h' => 3600
  }.freeze

  public

  def self.convert_to_seconds(duration)
    duration_integer = duration.gsub(/(s|m|h)/,"").split[0]
    duration_token   = duration.gsub(/\d+/,"").split[0]

    raise ArgumentError, 'unrecognised token' unless duration_token.in?(TOKEN_TO_SECOND_MULTIPLIER.keys)

    duration_integer.to_i * TOKEN_TO_SECOND_MULTIPLIER[duration_token]
  end
end
