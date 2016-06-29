require 'app/google_auth_api'

describe GoogleAuthApi do
  let(:googleapis_host) { Settings.google.googleapis_host }
  subject { GoogleAuthApi }
  describe 'get_token' do
    it 'should call google api to exchange auth code for token' do
      auth_code = fake_string 'auth-code'
      token = fake_access_token
      stub_request(:post, "#{googleapis_host}/oauth2/v4/token")
        .with(body: {
                code: auth_code,
                client_id: Settings.google.client_id,
                client_secret: Settings.google.client_secret,
                grant_type: 'authorization_code',
                redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
              })
        .to_return(body: token.to_json)
      expect(subject.get_token(auth_code)).to eql(token)
    end

    it 'should raise error if response was not 200' do
      auth_code = fake_string 'auth-code'
      stub_request(:post, "#{googleapis_host}/oauth2/v4/token")
        .to_return(status: 400)
      expect(lambda do
        subject.get_token(auth_code)
      end).to raise_error(RestClient::BadRequest)
    end
  end

  describe 'refresh_token' do
    it 'should call google api to exchange auth code for token' do
      refresh_token = fake_string 'refresh-token'
      token = fake_access_token
      stub_request(:post, "#{googleapis_host}/oauth2/v4/token")
        .with(body: {
                refresh_token: refresh_token,
                client_id: Settings.google.client_id,
                client_secret: Settings.google.client_secret,
                grant_type: 'refresh_token'
              })
        .to_return(body: token.to_json)
      expect(subject.refresh_token(refresh_token)).to eql(token)
    end

    it 'should raise error if response was not 200' do
      refresh_token = fake_string 'refresh-token'
      stub_request(:post, "#{googleapis_host}/oauth2/v4/token")
        .to_return(status: 400)
      expect(lambda do
        subject.refresh_token(refresh_token)
      end).to raise_error(RestClient::BadRequest)
    end
  end
end
