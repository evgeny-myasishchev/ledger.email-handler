class EmailsProvider
  # Yield block for each available email
  def each(&_block)
    raise 'Not implemented'
  end

  def self.create(provider_settings)
    return InMemory.new(provider_settings['in-memory']) if provider_settings.key?('in-memory')
    return Pop3.new(provider_settings['pop3']) if provider_settings.key?('pop3')

    raise "Provider '#{provider_settings.keys.first}' is not supported"
  end

  # Used for testing purposes
  class InMemory < EmailsProvider
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

  class Pop3 < EmailsProvider
    attr_reader :settings
    def initialize(pop3_settings)
      @settings = pop3_settings
    end
  end
end
