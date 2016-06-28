require 'ffaker'
require 'jwt'

module FakeFactory
  def fake_access_token(id_token_email: fake_email, id_token_exp: Time.now.to_i + 30)
    id_token_payload = {
      'email' => id_token_email,
      'exp' => id_token_exp
    }

    {
      'access_token' => fake_string('access-token'),
      'token_type' => 'Bearer',
      'expires_in' => 3600,
      'refresh_token' => fake_string('refresh-token'),
      'id_token' => JWT.encode(id_token_payload, nil, 'none')
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
