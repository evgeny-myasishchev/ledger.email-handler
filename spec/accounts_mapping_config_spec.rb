require 'app/accounts_mapping_config'
require 'fileutils'

describe AccountsMappingConfig do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/accounts-mapping-cfg', __dir__)) }
  let(:accounts_mapping_dir) { data_dir.join('accounts-mapping') }
  let(:email) { fake_email }
  subject { described_class.new(data_dir) }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
  end

  describe 'add_mapping' do
    it 'should add new mapping to the file' do
      bank_account_1 = fake_string('bank-account-1')
      ledger_account_1 = fake_string('ledger-account-1')
      bank_account_2 = fake_string('bank-account-2')
      ledger_account_2 = fake_string('ledger-account-2')
      subject.add_mapping email, bank_account_1, ledger_account_1
      subject.add_mapping email, bank_account_2, ledger_account_2
      actual_data = JSON.parse(accounts_mapping_dir.join(email + '.json').read)
      expect(actual_data[bank_account_1]).to eql ledger_account_1
      expect(actual_data[bank_account_2]).to eql ledger_account_2
    end
  end

  describe 'get_mappings' do
    it 'should load mapping from file' do
      bank_account_1 = fake_string('bank-account-1')
      ledger_account_1 = fake_string('ledger-account-1')
      bank_account_2 = fake_string('bank-account-2')
      ledger_account_2 = fake_string('ledger-account-2')
      mapping = {
        bank_account_1 => ledger_account_1,
        bank_account_2 => ledger_account_2
      }
      FileUtils.mkdir_p accounts_mapping_dir
      accounts_mapping_dir.join(email + '.json').write JSON.generate(mapping)
      expect(subject.get_mappings(email)).to eql(mapping)
    end
  end
end
