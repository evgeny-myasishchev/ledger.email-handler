require 'mail'
require 'app/lib/services'
require 'app/email_handler_service'
require 'app/email_parser'

describe EmailHandlerService do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email-handler-service-spec-data', __dir__)) }
  let(:email_config) { EmailConfig::InMemory.new }
  let(:services) do
    Services.new(data_dir) { |svc| svc[:email_config] = email_config }
  end

  let(:user1) { fake_email('user-email1') }
  let(:user2) { fake_email('user-email2') }
  let(:bic1) { fake_string('BIC1') }
  let(:bic2) { fake_string('BIC2') }

  # Data of user1
  let(:bic1_user1_mail) do
    (1..3).map { |i| Mail.new 'Message-ID' => "#{bic1}-user1-mail-#{i}" }
  end
  let(:bic2_user1_mail) do
    (1..3).map { |i| Mail.new 'Message-ID' => "#{bic2}-user1-mail-#{i}" }
  end
  let(:user1_raw_tran) do
    [bic1_user1_mail, bic2_user1_mail]
      .flatten
      .map { |mail| build_raw_transaction id: mail['Message-ID'].to_s }
  end

  # Data of user2
  let(:bic2_user2_mail) do
    (1..3).map { |i| Mail.new 'Message-ID' => "#{bic2}-user2-mail-#{i}" }
  end
  let(:user2_raw_tran) do
    bic2_user2_mail.map { |mail| build_raw_transaction id: mail['Message-ID'].to_s }
  end

  let(:user1_access_token) { fake_access_token(id_token_email: user1) }
  let(:user2_access_token) { fake_access_token(id_token_email: user2) }

  let(:dummy_api_user1) { DummyLedgerApi.new }
  let(:dummy_api_user2) { DummyLedgerApi.new }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
    email_config.add_email_settings user1, bic1, 'in-memory' => bic1_user1_mail
    email_config.add_email_settings user1, bic2, 'in-memory' => bic2_user1_mail
    email_config.add_email_settings user2, bic1, 'in-memory' => bic2_user2_mail

    services.access_token_repo.save user1, user1_access_token
    services.access_token_repo.save user2, user2_access_token

    all_raw_tran = user1_raw_tran + user2_raw_tran
    allow(EmailParser).to receive(:parse_email) do |_bic, mail|
      id = mail['Message-ID'].to_s
      all_raw_tran.detect(->() { raise 'Not found' }) { |t| t[:id] == id }
    end

    user1_raw_tran.each do |raw_tran|
      services.accounts_mapping_config.add_mapping user1, raw_tran[:bank_account], "ledger-account-for-#{raw_tran[:bank_account]}"
    end

    user2_raw_tran.each do |raw_tran|
      services.accounts_mapping_config.add_mapping user2, raw_tran[:bank_account], "ledger-account-for-#{raw_tran[:bank_account]}"
    end

    allow(LedgerApi).to receive(:create).with(user1_access_token['id_token']).and_return(dummy_api_user1)
    allow(LedgerApi).to receive(:create).with(user2_access_token['id_token']).and_return(dummy_api_user2)
  end

  describe 'handle_emails' do
    it 'should iterate through all user emails, parse them and submit to ledger' do
      described_class.handle_emails(services)
      expect(dummy_api_user1.reported_pending_transactions.length).to eql user1_raw_tran.length
      user1_accounts_mapping_cfg = services.accounts_mapping_config.get_mappings user1
      user1_raw_tran.each do |raw_tran|
        pending_tran = PendingTransaction.build user1_accounts_mapping_cfg, raw_tran
        expect(dummy_api_user1.reported_pending_transactions).to include(pending_tran)
      end
      user2_accounts_mapping_cfg = services.accounts_mapping_config.get_mappings user2
      user2_raw_tran.each do |raw_tran|
        pending_tran = PendingTransaction.build user2_accounts_mapping_cfg, raw_tran
        expect(dummy_api_user2.reported_pending_transactions).to include(pending_tran)
      end
    end
  end
end
