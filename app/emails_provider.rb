require 'net/pop'
require 'mail'

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
    Log = Logger.get self

    attr_reader :emails
    def initialize(emails)
      Log.debug "Initializing in-memory provider with #{emails.length} emails."
      @emails = emails.dup
    end

    def each
      @emails.length.times do
        yield @emails[0]
        @emails.delete_at 0
      end
    end
  end

  # Pop3 provider settings
  # {
  #   address: 'pop.gmail.com',
  #   port: 995, #Pop3 port. Default 995
  #   requires_ssl: true, # Optional, default true
  #   account: 'name@gmail.com',
  #   password: 'password',
  #   autoremove: false # Optional, default false. Note: set to true if your provider will fetch again previously fetched.
  # }
  class Pop3 < EmailsProvider
    Log = Logger.get self

    attr_reader :settings
    def initialize(pop3_settings)
      Log.debug 'Initializing pop3 provider'
      @settings = {
        'address' => nil,
        'port' => nil,
        'requires_ssl' => true,
        'acccount' => nil,
        'password' => nil,
        'autoremove' => false
      }.merge pop3_settings
    end

    def each(&block)
      requires_ssl = @settings['requires_ssl']
      Log.debug "Starting pop3 session. Address: #{@settings['address']}:#{@settings['port']}, ssl: #{requires_ssl}"
      pop3 = Net::POP3.new(@settings['address'], @settings['port'])
      pop3.enable_ssl if requires_ssl
      pop3.start(@settings['account'], @settings['password'])
      begin
        yield_each pop3, &block
      ensure
        Log.debug 'Closing pop3 session'
        pop3.finish
      end
    end

    private

    def yield_each(pop3)
      pop3.each_mail do |pop_mail|
        mail = Mail.new pop_mail.pop
        message_id = mail['Message-ID']
        Log.debug "Fetched mail id=#{message_id}"
        yield mail
        if @settings['autoremove']
          Log.debug "Mail id=#{message_id} processed. Removing"
          pop_mail.delete
        else
          Log.debug "Mail id=#{message_id} processed and will NOT be removed"
        end
      end
    end
  end
end
