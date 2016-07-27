class EmailConfig
  Log = Logger.get self
  def initialize(data_dir)
    @config_dir = data_dir.join('email-config')
  end

  # Email provider settings example
  # {
  #   'AGRIUAUK' => {
  #     pop3: {
  #       address: 'pop.gmail.com',
  #       port: 995,
  #       user_name: '<username>',
  #       password: '<password>',
  #       enable_ssl: true
  #     }
  #   }
  # }

  # user_email - email of the ledger user_email
  # bic - BIC to fetch email
  # settings - Emails provider settings to get emails (see format above)
  def add_email_settings(user_email, bic, emails_provider_settings)
    Log.debug "Adding email settings for user: #{user_email}"
    @config_dir.mkdir unless @config_dir.exist?
    config_file = @config_dir.join(user_email)
    settings = {
      bic => emails_provider_settings
    }
    config_file.write JSON.generate settings
  end

  # Returns emails provider settings for given ledger user_email (see format above)
  def get_email_settings(user_email)
  end
end
