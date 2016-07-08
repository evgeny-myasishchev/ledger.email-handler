require File.expand_path 'boot', __dir__
require 'uri'
require 'app/bootstrap'
require 'app/google_auth_api'
require 'app/token'
wrequire 'app/ledger_api'
require 'jwt'

desc 'Show code prompt'
task :'get-auth-code-url' do
  params = {
    response_type: 'code',
    client_id: Settings.google.client_id,
    redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
    scope: 'email',
    access_type: 'offline'
  }
  auth_uri = URI.parse 'https://accounts.google.com/o/oauth2/v2/auth'
  auth_uri.query = params.map { |k, v| "#{k}=#{v}" }.join('&')
  puts 'Copy url below and paste it into the browser.'
  puts 'Then follow the instruction and use rake get-access-token[code] with the code displayed'
  puts 'The url:'
  puts auth_uri
end

desc 'Add access/id token for given auth code'
task :'add-token', [:auth_code] do |_t, a|
  unless a.auth_code
    puts 'auth_code has not been provided. Please use rake get-auth-code-url to get auth code'
    exit 1
  end

  token_json = GoogleAuthApi.get_token a.auth_code

  token = JSON.parse token_json
  id_token_payload = JWT.decode(token['id_token'], nil, false)[0]

  services = Bootstrap.new.create_services
  services.access_token_repo.save(id_token_payload['email'], token)
end

desc 'Refresh token'
task :'refresh-token', [:email] do |_t, a|
  unless a.email
    puts 'email has not been provided. Please use rake get-auth-code-url to get auth code'
    exit 1
  end

  services = Bootstrap.new.create_services
  token = services.access_token_repo.load(a.email)
  Token.refresh_if_needed token, services
end

desc 'Show ledger accounts'
task :'show-ledger-accounts', [:email] do |_t, a|
  unless a.email
    puts 'email has not been provided.'
    exit 1
  end
  services = Bootstrap.new.create_services
  id_token = Token.get_id_token a.email, services
  ledger_api = LedgerApi.create id_token
  puts ledger_api.accounts
end
