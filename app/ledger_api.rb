require 'app/lib/request'

class LedgerApi
  Log = Logger.get(self)

  def initialize(session, _csrf_token)
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
    sessions_url = "#{Settings.ledger.api_host}/api/sessions"
    puts "sessions_url: #{sessions_url}"
    Log.debug "Posting google_id_token onto #{sessions_url}"
    session_data = Request.post sessions_url, params
    new(nil, session_data['form_authenticity_token'])
  end
end
