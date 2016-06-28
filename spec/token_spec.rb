require 'app/token'
require 'app/access_token_repository'
require 'app/google_auth_api'
require 'app/lib/services'
require 'jwt'

describe Token do
  let(:services) do
    instance_double(Services, access_token_repo: instance_double(AccessTokenRepository))
  end

  describe 'refresh_if_needed' do
    it 'should return token if it has not expired' do
      token = fake_access_token
      expect(Token.refresh_if_needed(token, services)).to be token
    end

    it 'should use google api to refresh the token and save it' do
      email = fake_email
      expired_token = fake_access_token id_token_email: email, id_token_exp: Time.now.to_i - 100
      new_token = fake_access_token id_token_exp: Time.now.to_i + 100
      new_token.delete 'refresh_token'

      refreshed_token = {
        'refresh_token' => expired_token['refresh_token']
      }.merge(new_token)

      expect(GoogleAuthApi).to receive(:refresh_token).with(expired_token['refresh_token']).and_return(new_token)
      expect(services.access_token_repo).to receive(:save).with(email, refreshed_token)
      expect(Token.refresh_if_needed(expired_token, services)).to eql(refreshed_token)
    end
  end
end
