require 'app/email_config'

describe EmailConfig do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/email_config_data_dir', __dir__)) }
  let(:email_config_dir) { data_dir.join('email-config') }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
  end

  describe 'add_email_settings' do
    xit 'should create new config file with user settings for given bic' do
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
