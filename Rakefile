require File.expand_path 'boot', __dir__
Dir.glob('tasks/*.rake').each { |r| load r }
require 'uri'
require 'app/bootstrap'
require 'app/google_auth_api'
require 'app/token'
require 'app/ledger_api'
require 'app/pending_transaction'
require 'app/email_handler_service'
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

  token = GoogleAuthApi.get_token a.auth_code
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
task :'show-ledger-accounts', [:user_email] do |_t, a|
  unless a.user_email
    puts 'user_email has not been provided.'
    exit 1
  end
  services = Bootstrap.new.create_services
  id_token = Token.get_id_token a.user_email, services
  ledger_api = LedgerApi.create id_token
  accounts = ledger_api.accounts
  puts JSON.pretty_generate(accounts)
end

desc 'Add mapping of bank account to ledger account'
task :'add-account-mapping', [:user_email, :bank_account, :ledger_account_id] do |_t, a|
  unless a.user_email
    puts 'user_email has not been provided.'
    exit 1
  end
  unless a.bank_account
    puts 'bank_account has not been provided.'
    exit 1
  end
  unless a.ledger_account_id
    puts 'ledger_account_id has not been provided.'
    exit 1
  end
  services = Bootstrap.new.create_services
  services.accounts_mapping_config.add_mapping a.user_email, a.bank_account, a.ledger_account_id
  puts "Account mapping added. User: #{a.user_email}, bank account: #{a.bank_account}, ledger account: #{a.ledger_account_id}"
end

desc 'Handle emails for all configured users'
task :'handle-emails' do
  services = Bootstrap.new.create_services
  begin
    EmailHandlerService.handle_emails services
  rescue => e
    Logger.get(EmailHandlerService).error %(Failed to handle emails: #{e}\nBacktrace:\n  #{e.backtrace.join("\n  ")})
    raise
  end
end

desc 'Add email config'
task :'add-email-config', [:user_email, :bic, :settings] do |_t, a|
  unless a.user_email
    puts 'user_email should be provided'
    exit 1
  end
  unless a.bic
    puts 'bic should be provided'
    exit 1
  end
  unless a.settings
    puts 'settings should be provided'
    exit 1
  end
  services = Bootstrap.new.create_services

  puts "Adding email config. User: #{a.user_email}, BIC: #{a.bic}"
  puts 'Settings:'
  puts a.settings
  provider_settings = JSON.parse(a.settings)
  services.email_config.add_email_settings a.user_email, a.bic, provider_settings
end
