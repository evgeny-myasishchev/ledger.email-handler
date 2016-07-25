require 'mail'
require 'app/emails_provider'

describe EmailsProvider do
  describe described_class::InMemoryEmailsProvider do
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
