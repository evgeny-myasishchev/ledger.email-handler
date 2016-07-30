class PendingTransaction
  INCOME_TYPE_ID = 1
  EXPENSE_TYPE_ID = 2

  attr_reader :data

  def initialize(id:, amount:, date: DateTime.now, comment:, account_id:, type_id:)
    @data = {
      id: id,
      amount: amount,
      date: date,
      comment: comment,
      account_id: account_id,
      type_id: type_id
    }
  end

  def inspect
    "PendingTransaction#{@data.to_json}"
  end

  def self.build(accounts_mapping_cfg, raw_transaction)
    bank_account = raw_transaction[:bank_account]
    unless accounts_mapping_cfg.key?(bank_account)
      raise "Can not build pending transaction id='#{raw_transaction[:id]}'. Mapping for bank account '#{bank_account}' not found."
    end
    ledger_account_id = accounts_mapping_cfg[bank_account]
    new(id: raw_transaction[:id],
        amount: raw_transaction[:amount],
        date: raw_transaction[:date],
        comment: raw_transaction[:comment],
        account_id: ledger_account_id,
        type_id: raw_transaction[:type_id])
  end
end
