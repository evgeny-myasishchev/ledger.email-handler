require 'mail'
require 'app/email_parser'
require 'app/email_parser/AGRIUAUK'
require 'app/email_parser/TEMPLATE'

describe EmailParser do
  subject { described_class }
  let(:mail) { Mail.new 'Message-ID' => "msg-id-#{SecureRandom.hex(10)}" }
  describe 'parse_email' do
    it 'should use bic specific parser to parse email' do
      agriuauk_parser = EmailParser::AGRIUAUK
      template_parser = EmailParser::TEMPLATE
      allow(agriuauk_parser).to receive(:parse_email) { { value: 'dummy-result-1' } }
      allow(template_parser).to receive(:parse_email) { { value: 'dummy-result-2' } }

      expect(subject.parse_email('AGRIUAUK', mail)[:value]).to eql('dummy-result-1')
      expect(agriuauk_parser).to have_received(:parse_email).with(mail)

      expect(subject.parse_email('TEMPLATE', mail)[:value]).to eql('dummy-result-2')
      expect(template_parser).to have_received(:parse_email).with(mail)
    end

    it 'should raise error if no such parser' do
      not_existing_bic = "NOT-EXISTING-BIC-#{SecureRandom.hex(10)}"
      expect do
        subject.parse_email not_existing_bic, mail
      end.to raise_error EmailParser::ParserError, "Can not find parser for bic: #{not_existing_bic}"
    end

    it 'should assign transactionId from mail for each transaction' do
      template_parser = EmailParser::TEMPLATE
      allow(template_parser).to receive(:parse_email) { { value: 'dummy-result-2' } }
      transaction = subject.parse_email('TEMPLATE', mail)
      expected_id = mail['Message-ID'].to_s
      expect(transaction[:id]).to eql(expected_id)
    end
  end
end
