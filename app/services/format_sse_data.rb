class FormatSseData
  private

  attr_reader :data

  public

  def self.call(data)
    new(data).call
  end

  def initialize(data)
    @data = data
  end

  def call
    return { } unless data.start_with?('data:')

    remove_data_prefix
    convert_to_json

    return data if data.empty?

    get_object
  end

  private

  def remove_data_prefix
    @data = data[6..-1]
  end

  def convert_to_json
    @data = JSON.parse(data)
  end

  def get_object
    @data = data.values[0]
  end
end
