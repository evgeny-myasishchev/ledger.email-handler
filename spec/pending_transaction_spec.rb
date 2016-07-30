require 'app/accounts_mapping_config'
require 'app/pending_transaction'

describe PendingTransaction do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/pending-transaction-spec', __dir__)) }
  let(:accounts_mapping_cfg) { AccountsMappingConfig.new(data_dir) }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
  end

  describe 'build' do
    let(:bic) { fake_string('BIC') }
    let(:user_email) { fake_email('email1') }

    let(:ledger_account_1) { fake_string('la-1') }
    let(:ledger_account_2) { fake_string('la-2') }

    let(:bank_account_1) { fake_string('ba-1') }
    let(:bank_account_2) { fake_string('ba-2') }

    before(:each) do
      accounts_mapping_cfg.add_mapping user_email, bank_account_1, ledger_account_1
      accounts_mapping_cfg.add_mapping user_email, bank_account_2, ledger_account_2
    end

    it 'should build pending transaction from given raw transaction and mapping config' do
      raw_t1 = build_raw_transaction(bank_account: bank_account_1)
      raw_t2 = build_raw_transaction(bank_account: bank_account_2)

      t1 = described_class.build(accounts_mapping_cfg.get_mappings(user_email), raw_t1)
      t2 = described_class.build(accounts_mapping_cfg.get_mappings(user_email), raw_t2)

      expect(t1.data).to eql(id: raw_t1[:id],
                             amount: raw_t1[:amount],
                             date: raw_t1[:date],
                             comment: raw_t1[:comment],
                             account_id: ledger_account_1,
                             type_id: raw_t1[:type_id])

      expect(t2.data).to eql(id: raw_t2[:id],
                             amount: raw_t2[:amount],
                             date: raw_t2[:date],
                             comment: raw_t2[:comment],
                             account_id: ledger_account_2,
                             type_id: raw_t2[:type_id])
    end

    it 'should raise error if mapping for bank account not found' do
      raw_tran = build_raw_transaction
      expect do
        described_class.build(accounts_mapping_cfg.get_mappings(user_email), raw_tran)
      end.to raise_error "Can not build pending transaction id='#{raw_tran[:id]}'. Mapping for bank account '#{raw_tran[:bank_account]}' not found."
    end
  end
end
