require 'app/email_config'

describe EmailConfig do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email_config_data_dir', __dir__)) }
  let(:email_config_dir) { data_dir.join('email-config') }

  let(:email1) { fake_email('email1') }
  let(:email2) { fake_email('email2') }
  let(:bic1) { fake_string('BIC1') }
  let(:bic2) { fake_string('BIC2') }

  provider_settings1 = { 'option1' => fake_string('value1'), 'option2' => fake_string('value2') }
  provider_settings2 = { 'option1' => fake_string('value1'), 'option2' => fake_string('value2') }

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

    xit 'should add new bic section to existing settings file' do
    end

    xit 'should update existing section of bic settings' do
    end
  end

  describe 'get_email_settings' do
    xit 'should return settings of given user' do
    end

    xit 'should raise error if settings not found' do
    end
  end
end
