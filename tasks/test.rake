namespace :test do
  desc 'Report pending transaction'
  task :'report-pending-transaction', [:email, :id, :amount, :comment, :account_id] do |_t, a|
    unless a.email
      puts 'email has not been provided.'
      exit 1
    end
    services = Bootstrap.new.create_services
    id_token = Token.get_id_token a.email, services
    ledger_api = LedgerApi.create id_token
    transaction = PendingTransaction.new id: a.id,
                                         amount: a.amount,
                                         comment: a.comment,
                                         account_id: a.account_id,
                                         type_id: PendingTransaction::EXPENSE_TYPE_ID
    ledger_api.report_pending_transaction transaction
  end

  desc 'Send to mailtrap'
  task :'send-to-mailtrap', [:user, :password, :message_path] do |_t, a|
    require 'net/smtp'
    message = Mail.new File.read a.message_path
    message['Message-ID'] = "fake-message-#{SecureRandom.hex(20)}"

    Net::SMTP.start('mailtrap.io', 2525, 'mailtrap.io', a.user, a.password, :cram_md5) do |smtp|
      smtp.send_message message.to_s, 'from@mailtrap.io', 'to@mailtrap.io'
    end
  end

  desc 'Test pop3 email provider'
  task :'pop3-fetch', [:user_email, :bic] do |_t, a|
    services = Bootstrap.new.create_services
    email_settings = services.email_config.get_email_settings a.user_email
    raise "Settings for user #{a.user_email} not found" unless email_settings
    raise "Settings for bic #{a.bic} not found" unless email_settings.key?(a.bic)

    provider_settings = email_settings[a.bic]
    raise 'Not a pop3 provider' unless provider_settings['pop3']
    provider_settings['pop3']['autoremove'] = false
    require 'app/emails_provider'
    provider = EmailsProvider.create provider_settings
    provider.each do |mail|
      puts mail
    end
  end

  desc 'Invoke parser'
  task :'invoke-parser', [:bic, :message_path] do |_t, a|
    message = Mail.new File.read a.message_path
    transaction = EmailParser.parse_email a.bic, message
    puts JSON.pretty_generate transaction
  end
end
