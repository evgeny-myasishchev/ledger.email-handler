namespace :test do
  desc 'Send to mailtrap'
  task :'send-to-mailtrap', [:user, :password, :message_path] do |_t, a|
    require 'net/smtp'
    message = File.read a.message_path

    Net::SMTP.start('mailtrap.io', 2525, 'mailtrap.io', a.user, a.password, :cram_md5) do |smtp|
      smtp.send_message message, 'from@mailtrap.io', 'to@mailtrap.io'
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
end
