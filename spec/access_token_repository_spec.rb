require 'app/access_token_repository'
require 'fileutils'

describe AccessTokenRepository do
  let(:data_dir) { Pathname.new(File.expand_path('../tmp/access-token-repo', __dir__)) }
  let(:access_tokens_dir) { data_dir.join('access-tokens') }
  subject { described_class.new(data_dir) }

  before(:each) do
    FileUtils.rm_rf access_tokens_dir if access_tokens_dir.exist?
    FileUtils.mkdir_p access_tokens_dir
  end

  describe 'save' do
    let(:email) { FFaker::Internet.email }
    let(:token) { fake_access_token }

    it 'should save the access token to a data_dir/access-tokens' do
      subject.save email, token
      expect(access_tokens_dir.join(email)).to exist
      expect(JSON.parse(access_tokens_dir.join(email).read)).to eql token
    end

    it 'should read the token from file' do
      access_tokens_dir.join(email).write(JSON.generate(token))
      expect(subject.load(email)).to eql(token)
    end
  end
end
