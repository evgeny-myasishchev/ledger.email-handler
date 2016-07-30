require 'mail'
require 'app/lib/services'
require 'app/email_handler_service'

describe EmailHandlerService do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email-handler-service-spec-data', __dir__)) }
  let(:email_config) { EmailConfig::InMemory.new }
  let(:services) do
    Services.new(data_dir) { |svc| svc[:email_config] = email_config }
  end

  let(:email1) { fake_email('email1') }
  let(:email2) { fake_email('email2') }
  let(:bic1) { fake_string('BIC1') }
  let(:bic2) { fake_string('BIC2') }

  let(:mail111) { Mail.new 'Message-ID' => 'email111' }
  let(:mail112) { Mail.new 'Message-ID' => 'email112' }
  let(:mail121) { Mail.new 'Message-ID' => 'email121' }
  let(:mail122) { Mail.new 'Message-ID' => 'email122' }
  let(:mail211) { Mail.new 'Message-ID' => 'mail211' }
  let(:mail212) { Mail.new 'Message-ID' => 'mail212' }

  let(:provider_settings11) { { 'in-memory' => [mail111, mail112] } }
  let(:provider_settings12) { { 'in-memory' => [mail121, mail122] } }
  let(:provider_settings21) { { 'in-memory' => [mail211, mail212] } }

  let(:email1_access_token) { fake_access_token(id_token_email: email1) }
  let(:email2_access_token) { fake_access_token(id_token_email: email2) }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
    email_config.add_email_settings email1, bic1, provider_settings11
    email_config.add_email_settings email1, bic2, provider_settings12
    email_config.add_email_settings email2, bic1, provider_settings21

    services.access_token_repo.save email1, email1_access_token
    services.access_token_repo.save email2, email2_access_token
  end

  describe 'handle_emails' do
    xit 'should iterate through all user emails, parse them and submit to ledger' do
    end
  end
end
