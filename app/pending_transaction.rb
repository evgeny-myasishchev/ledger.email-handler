class PendingTransaction < Struct.new(transaction_id, amount, date, comment, account_id, type_id) do
    def self.build accounts_mapping_cfg, raw_transaction
        # map
    end
end
