RSpec::Matchers.define :be_valid do |expected|
  match_for_should do |actual|
    actual.valid?
  end

  failure_message_for_should do |actual|
    if actual.is_a?(Service::Result)
      "expected service to succeed, but it failed with: #{actual.error.to_json}"
    else
      "expected #{actual} to be valid"
    end
  end

  failure_message_for_should_not do |actual|
    if actual.is_a?(Service::Result)
      "expected service to fail, but it resulted with: #{actual.output.to_json}"
    else
      "expected #{actual} not to be valid"
    end
  end
end