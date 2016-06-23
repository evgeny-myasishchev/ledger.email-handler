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
end

RSpec.configure do |config|
  config.include FakeFactory
end
