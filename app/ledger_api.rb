require 'app/lib/request'

class LedgerApi
  CSRF_TOKEN_NAME = 'form_authenticity_token'.freeze
  CSRF_HEADER_NAME = 'X-CSRF-Token'.freeze
  SESSION_COOKIE_NAME = '_ledger_session_v1'.freeze
  Log = Logger.get(self)

  attr_reader :session, :csrf_token

  def initialize(session, csrf_token)
    @session = session
    @csrf_token = csrf_token
  end

  def report_pending_transaction(pending_transaction)
    transactions_url = "#{Settings.ledger.api_host}/pending-transactions"
    params = {
      'Cookie' => "#{SESSION_COOKIE_NAME}=#{@session}",
      'Content-Type' => 'application/json',
      CSRF_HEADER_NAME => @csrf_token
    }
    Request.post transactions_url, data: pending_transaction.data.to_json, params: params
  end

  def accounts
    accounts_url = "#{Settings.ledger.api_host}/accounts"
    response = Request.get accounts_url, 'Cookie' => "#{SESSION_COOKIE_NAME}=#{@session}", accept: :json
    JSON.parse response
  end

  def self.create(id_token)
    params = {
      google_id_token: id_token
    }
    sessions_url = "#{Settings.ledger.api_host}/api/sessions"
    Log.debug "Posting google_id_token onto #{sessions_url}"
    response = Request.post sessions_url, data: params
    response_data = JSON.parse response.body
    new(response.cookies[SESSION_COOKIE_NAME], response_data[CSRF_TOKEN_NAME])
  end
end
