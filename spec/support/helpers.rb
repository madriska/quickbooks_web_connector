module QuickbooksWebConnectorTestHelpers

  # Execute the block setting the given values and restoring old values after
  # the block is executed.
  def swap(object, new_values)
    old_values = {}
    new_values.each do |key, value|
      old_values[key] = object.send(key)
      object.send("#{key}=", value)
    end
    yield
  ensure
    old_values.each do |key, value|
      object.send("#{key}=", value)
    end
  end

end

RSpec.configure do |config|
  config.include QuickbooksWebConnectorTestHelpers
end