require 'spec_helper'
require 'app/ledger_api'

describe LedgerApi do
  let(:api_host) { Settings.ledger.api_host }
  let(:form_authenticity_token) { "form-auth-token-#{SecureRandom.hex(10)}" }
  let(:ledger_session_cookie) { "session-cookie-#{SecureRandom.hex(10)}" }
  subject { described_class.new(ledger_session_cookie, form_authenticity_token) }
  describe 'create' do
    let(:google_id_token) { "google-id-token-#{SecureRandom.hex(10)}" }
    before(:each) do
      allow(LedgerApi).to receive(:new).and_call_original
      stub_request(:post, "#{api_host}/api/sessions")
        .with(body: { google_id_token: google_id_token })
        .to_return(
          body: { form_authenticity_token: form_authenticity_token }.to_json,
          headers: { 'Set-Cookie' => "#{LedgerApi::SESSION_COOKIE_NAME}=#{ledger_session_cookie}" }
        )
    end

    it 'should initiate new session and create new api instance with the sesion cookie and the result' do
      api = LedgerApi.create(google_id_token)
      expect(api).to be_a(LedgerApi)
      expect(api.csrf_token).to eql(form_authenticity_token)
      expect(api.session).to eql(ledger_session_cookie)
    end

    it 'should raise error if sessions api returns non 200 status code' do
      stub_request(:post, "#{api_host}/api/sessions")
        .with(body: { google_id_token: google_id_token })
        .to_return(status: 500)
      expect do
        LedgerApi.create(google_id_token)
      end.to raise_error RestClient::InternalServerError
    end
  end

  describe 'accounts', focus: true do
    it 'should GET /accounts' do
      accounts = [
        { 'fake1' => 'fake-account-1' },
        { 'fake2' => 'fake-account-2' },
        { 'fake3' => 'fake-account-3' }
      ]
      stub_request(:get, 'https://test.my-ledger.com/accounts')
        .with(headers: { 'Cookie' => "#{LedgerApi::SESSION_COOKIE_NAME}=#{ledger_session_cookie}" })
        .to_return(body: accounts.to_json, headers: { 'Content-Type' => 'application/json' })

      expect(subject.accounts).to eql accounts
    end
  end
end
