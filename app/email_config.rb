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

  class Base
    # user_email - email of the ledger user_email
    # bic - BIC to fetch email
    # settings - Emails provider settings to get emails (see format above)
    def add_email_settings(user_email, bic, emails_provider_settings)
    end

    # Returns emails provider settings for given ledger user_email (see format above)
    def get_email_settings(user_email)
    end

    # Returns hash of results returned by get_email_settings keyed by user_email:
    # {
    #   'mail1@domain.com' => { ...object returned by get_email_settings... },
    #   'mail2@domain.com' => { ...object returned by get_email_settings... }
    # }
    def all_email_settings
    end
  end

  # In memory email config
  class InMemory < Base
    def initialize
      @storage = {}
    end

    def add_email_settings(user_email, bic, emails_provider_settings)
      user_store = @storage.fetch(user_email, {})
      user_store[bic] = emails_provider_settings
      @storage[user_email] = user_store
    end

    def get_email_settings(user_email)
      raise "Email settings for user '#{user_email}' not found" unless @storage.key?(user_email)
      @storage[user_email]
    end

    def all_email_settings
      @storage.dup
    end
  end

  # File based email config
  class FS < Base
    Log = Logger.get self

    def initialize(data_dir)
      @config_dir = data_dir.join('email-config')
    end

    def add_email_settings(user_email, bic, emails_provider_settings)
      Log.info "Adding email settings for user: #{user_email}, bic: #{bic}"
      FileUtils.mkdir_p @config_dir unless @config_dir.exist?
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
      config_file.write JSON.pretty_generate settings
    end

    # Returns emails provider settings for given ledger user_email (see format above)
    def get_email_settings(user_email)
      config_file = @config_dir.join(user_email)
      raise "Email settings for user '#{user_email}' not found" unless config_file.exist?
      JSON.parse config_file.read
    end

    def all_email_settings
      Hash[@config_dir.children(false).collect do |path|
        [path.basename.to_s, get_email_settings(path.basename)]
      end]
    end
  end
end
