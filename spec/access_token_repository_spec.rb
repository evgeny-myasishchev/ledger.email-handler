require 'app/access_token_repository'
require 'fileutils'

describe AccessTokenRepository do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/access-token-repo', __dir__)) }
  let(:access_tokens_dir) { data_dir.join('access-tokens') }
  let(:email) { FFaker::Internet.email }
  let(:token) { fake_access_token }
  subject { described_class.new(data_dir) }

  before(:each) do
    FileUtils.rm_rf data_dir if data_dir.exist?
    FileUtils.mkdir_p data_dir
  end

  describe 'save' do
    it 'should save the access token to a data_dir/access-tokens' do
      subject.save email, token
      expect(access_tokens_dir.join(email + '.json')).to exist
      expect(JSON.parse(access_tokens_dir.join(email + '.json').read)).to eql token
    end
  end

  describe 'load' do
    it 'should read the token from file' do
      FileUtils.mkdir_p access_tokens_dir
      access_tokens_dir.join(email + '.json').write(JSON.generate(token))
      expect(subject.load(email)).to eql(token)
    end
  end
end
