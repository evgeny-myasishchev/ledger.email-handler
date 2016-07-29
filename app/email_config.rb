class EmailConfig
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

  # Returns an array of results returned by get_email_settings keyed by user_email:
  # [
  #   { 'mail@domain.com' => { ...object returned by get_email_settings... } }
  # ]
  def all_email_settings
  end

  # File based email config
  class FS
    Log = Logger.get self

    def initialize(data_dir)
      @config_dir = data_dir.join('email-config')
    end

    def add_email_settings(user_email, bic, emails_provider_settings)
      Log.debug "Adding email settings for user: #{user_email}, bic: #{bic}"
      @config_dir.mkdir unless @config_dir.exist?
      config_file = @config_dir.join(user_email)
      settings = nil
      if config_file.exist?
        Log.debug 'Updating existing settings'
        settings = JSON.parse config_file.read
      else
        Log.debug 'Initializing new settings'
        settings = {}
      end
      settings[bic] = emails_provider_settings
      config_file.write JSON.generate settings
    end

    # Returns emails provider settings for given ledger user_email (see format above)
    def get_email_settings(user_email)
      config_file = @config_dir.join(user_email)
      raise "Email settings for user '#{user_email}' not found" unless config_file.exist?
      JSON.parse config_file.read
    end

    def all_email_settings
      @config_dir.children(false).map do |path|
        { path.basename.to_s => get_email_settings(path.basename) }
      end
    end
  end
end
