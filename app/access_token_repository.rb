require 'json'

class AccessTokenRepository
  def initialize(data_dir)
    @access_tokens_dir = data_dir.join('access-tokens')
  end

  def save(email, access_token)
    @access_tokens_dir.join(email).write(JSON.pretty_generate(access_token))
  end

  def load(email)
    JSON.parse @access_tokens_dir.join(email).read
  end
end
