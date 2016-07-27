require 'app/email_config'

describe EmailConfig do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email_config_data_dir', __dir__)) }
  let(:email_config_dir) { data_dir.join('email-config') }

  let(:email1) { fake_email('email1') }
  let(:email2) { fake_email('email2') }
  let(:bic1) { fake_string('BIC1') }
  let(:bic2) { fake_string('BIC2') }

  let(:provider_settings1) { { 'option1' => fake_string('value1'), 'option2' => fake_string('value2') } }
  let(:provider_settings2) { { 'option1' => fake_string('value1'), 'option2' => fake_string('value2') } }

  subject { described_class.new(data_dir) }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
    subject.add_email_settings email1, bic1, provider_settings1
  end

  describe 'add_email_settings' do
    it 'should create new config file with user settings for given bic' do
      config_file = email_config_dir.join(email1)
      expect(config_file).to exist
      data = JSON.parse config_file.read
      expect(data).to eql(bic1 => provider_settings1)
    end

    it 'should add new bic section to existing settings file' do
      subject.add_email_settings email1, bic2, provider_settings2
      config_file = email_config_dir.join(email1)
      data = JSON.parse config_file.read
      expect(data).to eql(bic1 => provider_settings1,
                          bic2 => provider_settings2)
    end

    it 'should update existing section of bic settings' do
      subject.add_email_settings email1, bic1, provider_settings2
      config_file = email_config_dir.join(email1)
      data = JSON.parse config_file.read
      expect(data).to eql(bic1 => provider_settings2)
    end
  end

  describe 'get_email_settings' do
    it 'should return settings of given user' do
      expect(subject.get_email_settings(email1)).to eql(bic1 => provider_settings1)
    end

    it 'should raise error if settings not found' do
      expect { subject.get_email_settings(email2) }.to raise_error "Email settings for user '#{email2}' not found"
    end
  end
end
