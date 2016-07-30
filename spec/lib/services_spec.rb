require 'app/lib/services'

describe Services do
  let(:fake_data_dir) { Pathname.new(File.expand_path('../tmp/not-existing-data-dir', __dir__)) }

  describe 'initialize' do
    it 'should initialize services for given data dir' do
      expect(AccessTokenRepository).to receive(:new).with(fake_data_dir).and_call_original
      expect(AccountsMappingConfig).to receive(:new).with(fake_data_dir).and_call_original
      expect(EmailConfig::FS).to receive(:new).with(fake_data_dir).and_call_original
      subject = described_class.new(fake_data_dir)
      expect(subject.access_token_repo).to be_an_instance_of AccessTokenRepository
      expect(subject.accounts_mapping_config).to be_an_instance_of AccountsMappingConfig
      expect(subject.email_config).to be_an_instance_of EmailConfig::FS
    end

    it 'should allow injecting email_config' do
      email_config = double(EmailConfig::InMemory)
      subject = described_class.new(fake_data_dir) do |params|
        params[:email_config] = email_config
      end
      expect(subject.email_config).to be email_config
    end
  end
end
