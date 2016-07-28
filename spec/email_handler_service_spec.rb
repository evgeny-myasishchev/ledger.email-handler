require 'app/lib/services'
require 'app/email_handler_service'

describe EmailHandlerService do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email-handler-service-spec-data', __dir__)) }
  let(:services) { Services.new data_dir }

  let(:email1) { fake_email('email1') }
  let(:email2) { fake_email('email2') }
  let(:bic1) { fake_string('BIC1') }
  let(:bic2) { fake_string('BIC2') }

  let(:provider_settings11) { { 'option11' => fake_string('value11') } }
  let(:provider_settings12) { { 'option12' => fake_string('value12') } }
  let(:provider_settings21) { { 'option21' => fake_string('value21') } }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
    services.email_config.add_email_settings email1, bic1, provider_settings11
    services.email_config.add_email_settings email1, bic2, provider_settings12
    services.email_config.add_email_settings email2, bic1, provider_settings21
  end

  describe 'handle_emails' do
    xit 'should iterate through all user emails, parse them and submit to ledger' do
    end
  end
end
