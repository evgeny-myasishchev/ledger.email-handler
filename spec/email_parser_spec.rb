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

    it 'should assign transactionId from mail Message-ID (as sha256 hash) for each transaction' do
      template_parser = EmailParser::TEMPLATE
      allow(template_parser).to receive(:parse_email) { { value: 'dummy-result-2' } }
      transaction = subject.parse_email('TEMPLATE', mail)
      expected_id = Base64.urlsafe_encode64 Digest::SHA256.digest mail['Message-ID'].to_s
      expect(transaction[:id]).to eql(expected_id)
      expect(transaction[:id].length).to be <= 50
    end
  end

  describe EmailParser::BaseParser do
    describe 'extract_body' do
      subject do
        Class.new(described_class) do
          class << self
            public :extract_body
          end
        end
      end

      let(:mail_body) { fake_string 'mail-body' }
      let(:mail_body_base64) { Base64.encode64 mail_body }

      it 'should decode eamil body' do
        mail = Mail.new(body: mail_body_base64) do
          content_transfer_encoding 'base64'
        end
        expect(subject.extract_body(mail)).to eql(mail_body)
      end

      describe 'text/html' do
        it 'should handle html only emails' do
          str1 = fake_string('str1')
          str2 = fake_string('str2')
          html_body = "<h1>#{str1}</h1><br><div>#{str2}</div>"

          mail = Mail.new do
            body html_body
            content_type 'text/html; charset=UTF-8'
          end
          expect(mail.content_type).to start_with('text/html')
          expect(subject.extract_body(mail)).to eql("#{str1}#{str2}")
        end
      end

      describe 'multipart/alternative' do
        it 'should return decoded text/plain part' do
          mail = Mail.new
          mail.text_part = Mail::Part.new body: mail_body_base64 do
            content_transfer_encoding 'base64'
          end
          mail.html_part = Mail::Part.new body: '<h1>Should not get it</h1>' do
            content_transfer_encoding 'base64'
          end
          expect(mail.content_type).to start_with('multipart/alternative')
          expect(subject.extract_body(mail)).to eql(mail_body)
        end
      end

      describe 'multipart/mixed' do
        it 'should return decoded text/plain part' do
          content = mail_body_base64
          mail = Mail.new do
            part content_type: 'multipart/alternative' do |p|
              p.part content_type: 'text/plain', body: content, content_transfer_encoding: 'base64'
              p.part content_type: 'text/html', body: '<h1>Should not get it</h1>'
            end
          end
          expect(mail.content_type).to start_with('multipart/mixed')
          expect(subject.extract_body(mail)).to eql(mail_body)
        end

        it 'should return converted to plain text text/html part if no text part' do
          str1 = fake_string('str1')
          str2 = fake_string('str2')
          html_body = "<h1>#{str1}</h1><br><div>#{str2}</div>"
          html_body_base64 = Base64.encode64 html_body

          mail = Mail.new
          mail.html_part = Mail::Part.new body: html_body_base64 do
            content_transfer_encoding 'base64'
          end
          expect(mail.content_type).to start_with('multipart/mixed')
          expect(subject.extract_body(mail)).to eql("#{str1}#{str2}")
        end

        it 'should raise error if no text part found' do
          mail = Mail.new message_id: fake_string('msg-id') do
            part content_type: 'multipart/alternative' do |p|
              p.part content_type: 'text/other', body: '<h1>Should not get it</h1>'
            end
          end
          expect(mail.content_type).to start_with('multipart/mixed')
          expect { subject.extract_body(mail) }.to raise_error "Text or html part not found while parsing message: #{mail['Message-ID']}"
        end
      end
    end
  end
end
