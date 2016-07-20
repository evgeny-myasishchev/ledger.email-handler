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

  def self.build(_accounts_mapping_cfg, _raw_transaction)
    # map
  end
end
