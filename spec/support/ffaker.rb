require 'ffaker'

module FakeFactory
  def fake_access_token
    {
      'access_token' => fake_string('access-token'),
      'token_type' => 'Bearer',
      'expires_in' => 3600,
      'refresh_token' => fake_string('refresh-token'),
      'id_token' => fake_string('id-token', length: 30)
    }
  end

  def fake_email
    FFaker::Internet.email
  end

  def fake_string(prefix, length: 10)
    prefix + '-' + FFaker::Lorem.characters[0..length]
  end
end

RSpec.configure do |config|
  config.include FakeFactory
end
