require 'app/ledger_api'

class DummyLedgerApi < LedgerApi
  attr_reader :reported_pending_transactions
  def initialize
    @reported_pending_transactions = []
  end

  def report_pending_transaction(pending_transaction)
    @reported_pending_transactions << pending_transaction
  end
end
