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
    session_data = Request.post "#{Settings.ledger.api_host}/api/sessions", params
    puts session_data
    new LedgerApi(session_data)
  end
end
