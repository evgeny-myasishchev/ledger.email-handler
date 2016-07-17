require 'app/lib/request'

class LedgerApi
  def initialize(session)
    @session = session
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
    session_data = Request.post "#{Settings.ledger.api_host}/api/sessions", params
    new(session_data)
  end
end
