require 'ffaker'

module FakeFactory
  def fake_access_token
    {
      'access_token' => "access-token-#{FFaker::Lorem.characters[0..10]}",
      'token_type' => 'Bearer',
      'expires_in' => 3600,
      'refresh_token' => "refresh-token-#{FFaker::Lorem.characters[0..10]}",
      'id_token' => "id-token-#{FFaker::Lorem.characters[0..30]}"
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
