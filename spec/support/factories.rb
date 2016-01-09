module Factories
  def a_user(params = {})
    attrs = {
      "name" => "Mysterious Mocker",
      "email" => "very@mysterious.com",
      "password" => "helloWorld123",
      "password_confirmation" => "helloWorld123",
      "nickname" => ""
    }.merge(params).with_indifferent_access

    if attrs[:nickname].blank?
      attrs[:nickname] = "random_#{SecureRandom.base64[0..12].gsub(/\W/, '_').downcase}"
    end

    User.create!(attrs)
  end
end