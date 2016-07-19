require 'app/lib/request'

class LedgerApi
  CSRF_TOKEN_NAME = 'form_authenticity_token'.freeze
  SESSION_COOKIE_NAME = '_ledger_session_v1'.freeze
  Log = Logger.get(self)

  attr_reader :session, :csrf_token

  def initialize(session, csrf_token)
    @session = session
    @csrf_token = csrf_token
  end

  def report_pending_transaction(pending_transaction)
  end

  def accounts
    @session
  end

  def self.create(id_token)
    params = {
      google_id_token: id_token
    }
    # TODO: Handle session cookie
    sessions_url = "#{Settings.ledger.api_host}/api/sessions"
    puts "sessions_url: #{sessions_url}"
    Log.debug "Posting google_id_token onto #{sessions_url}"
    response = Request.post sessions_url, params
    response_data = JSON.parse response.body
    new(response.cookies[SESSION_COOKIE_NAME], response_data[CSRF_TOKEN_NAME])
  end
end
