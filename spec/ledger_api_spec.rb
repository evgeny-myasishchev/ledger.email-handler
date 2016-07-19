require 'spec_helper'
require 'app/ledger_api'

describe LedgerApi do
  let(:api_host) { Settings.ledger.api_host }
  describe 'create' do
    let(:google_id_token) { "google-id-token-#{SecureRandom.hex(10)}" }
    let(:form_authenticity_token) { "form-auth-token-#{SecureRandom.hex(10)}" }
    let(:ledger_session_cookie) { "session-cookie-#{SecureRandom.hex(10)}" }
    before(:each) do
      allow(LedgerApi).to receive(:new).and_call_original
      stub_request(:post, "#{api_host}/api/sessions")
        .with(body: {
                google_id_token: google_id_token
              })
        .to_return({
                     body: {
                       form_authenticity_token: form_authenticity_token
                     }.to_json
                   },
                   headers: {
                     'Set-Cookie' => ledger_session_cookie
                   })
    end

    it 'should initiate new session and create new api instance with the sesion cookie and the result' do
      api = LedgerApi.create(google_id_token)
      expect(api).to be_a(LedgerApi)
    end

    it 'should raise error if sessions api returns non 200 status code' do
    end
  end
end
