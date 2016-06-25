$LOAD_PATH.unshift __dir__

require 'uri'
require 'app/bootstrap'
require 'jwt'

desc 'Show code prompt'
task :'get-auth-code-url' do
  params = {
    response_type: 'code',
    client_id: '127152602937-gpr5s8uce59ldqcqmivaf6ok0ksiovs5.apps.googleusercontent.com',
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

desc 'Get access token'
task :'add-access-token', [:auth_code] do |_t, a|
  unless a.auth_code
    puts 'auth_code has not been provided. Please use rake get-auth-code-url to get auth code'
    exit 1
  end

  require 'rest-client'

  params = {
    code: a.auth_code,
    client_id: '127152602937-gpr5s8uce59ldqcqmivaf6ok0ksiovs5.apps.googleusercontent.com',
    client_secret: '7ePL_3SJUcQ15nnUj3h8yK56',
    grant_type: 'authorization_code',
    redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
  }
  response = RestClient.post('https://www.googleapis.com/oauth2/v4/token', params) do |resp, req, result, &block|
    unless result.code == '200'
      puts 'Request failed. Response:'
      puts resp
    end
    resp.return! req, result, &block
  end

  access_token = JSON.parse response.body
  id_token = JWT.decode(access_token['id_token'], nil, false)[0]

  services = Bootstrap.new.create_services
  services.access_token_repo.save(id_token['email'], access_token)
end
