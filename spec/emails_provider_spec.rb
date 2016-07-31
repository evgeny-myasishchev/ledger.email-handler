require 'mail'
require 'app/emails_provider'

describe EmailsProvider do
  describe 'create' do
    it 'should create new instance of InMemory provider with emails as an input' do
      mail1 = Mail.new 'Message-ID' => 'email1'
      mail2 = Mail.new 'Message-ID' => 'email2'
      provider = described_class.create('in-memory' => [mail1, mail2])
      expect(provider).to be_an_instance_of EmailsProvider::InMemory
      expect(provider.emails).to eql [mail1, mail2]
    end

    it 'should create new instance of Pop3 provider with settings as an input' do
      pop3_settings = { 'pop3' => { settings: fake_string('fake-settings') } }
      provider = described_class.create(pop3_settings)
      expect(provider).to be_an_instance_of EmailsProvider::Pop3
      expect(provider.settings).to include pop3_settings['pop3']
    end

    it 'should raise error if provider is not known' do
      provider_id = fake_string 'not-supported'
      not_supported_settings = { provider_id => { settings: fake_string('fake-settings') } }
      expect { described_class.create(not_supported_settings) }.to raise_error "Provider '#{provider_id}' is not supported"
    end
  end

  describe described_class::InMemory do
    let(:email1) { Mail.new 'Message-ID' => 'email1' }
    let(:email2) { Mail.new 'Message-ID' => 'email2' }
    let(:email3) { Mail.new 'Message-ID' => 'email3' }
    let(:emails) { [email1, email2, email3] }
    subject { described_class.new emails }
    describe 'each' do
      it 'should iterate through emails provided with constructor' do
        actual = []
        subject.each { |e| actual << e }
        expect(actual.length).to eql(3)
      end

      it 'should remove email from internal list on successfull iteration' do
        removed = nil
        subject.each do |email|
          expect(subject.emails).not_to include(removed) if removed
          removed = email
        end
        expect(subject.emails).to be_empty
      end

      it 'should keep the email in a list if iteration fails' do
        removed = nil
        expect do
          subject.each do |email|
            raise 'Iteration failed' if removed
            removed = email
          end
        end.to raise_error 'Iteration failed'
        expect(subject.emails).not_to include(removed)
        expect(subject.emails.length).to eql 2
      end

      it 'should clone input array' do
        subject.each { |_e| }
        expect(subject.emails).to be_empty
        expect(emails).to eql [email1, email2, email3]
        expect(subject.emails).not_to be emails
      end
    end
  end
end
