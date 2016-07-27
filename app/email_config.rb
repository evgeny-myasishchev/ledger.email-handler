class EmailConfig
  def initialize(data_dir)
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
  end

  # Returns emails provider settings for given ledger user_email (see format above)
  def get_email_settings(user_email)
  end
end
