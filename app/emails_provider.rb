class EmailsProvider
  # Yield block for each available email
  def each(&_block)
    raise 'Not implemented'
  end

  def self.create(_provider_settings)
    # TODO: create and return provider using settings
    # Expected format see in email_config.rb
    # Short example: { bic => { pop3: {...} } }
  end

  # Used for testing purposes
  class InMemoryEmailsProvider < EmailsProvider
    attr_reader :emails
    def initialize(emails)
      @emails = emails.dup
    end

    def each
      @emails.length.times do
        yield @emails[0]
        @emails.delete_at 0
      end
    end
  end

  class Pop3EmailsProvider < EmailsProvider
  end
end
