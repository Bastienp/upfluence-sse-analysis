class Percentile
  private

  attr_reader :values

  public

  def initialize
    @values = []
  end

  def push(value)
    @values << value
  end

  def calculate(percentile)
    raise ArgumentError,
      'percentile should be between 0 excluded and 1 excluded' unless
      (0.to_f.next_float...1).include?(percentile)

    values.sort[values.length * percentile]
  end
end
