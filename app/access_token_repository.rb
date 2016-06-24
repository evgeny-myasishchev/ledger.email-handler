require 'json'

class AccessTokenRepository
  def initialize(data_dir)
    @access_tokens_dir = data_dir.join('access-tokens')
  end

  def save(email, access_token)
    FileUtils.mkdir_p @access_tokens_dir unless @access_tokens_dir.exist?
    target_file(email).write(JSON.pretty_generate(access_token))
  end

  def load(email)
    JSON.parse target_file(email).read
  end

  private def target_file(email)
    @access_tokens_dir.join(email + '.json')
  end
end
