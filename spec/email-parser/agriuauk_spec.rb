require 'mail'
require 'app/email_parser'
require 'app/email-parser/AGRIUAUK'

describe EmailParser::AGRIUAUK do
  subject { described_class }
  describe 'parse_email' do
    it 'should parse expense email' do
      mail = Mail.new do
        body %(
!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= 338UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
)
      end
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:type]).to eql PendingTransaction::EXPENSE_TYPE_ID
      expect(raw_transaction[:date]).to eql DateTime.iso8601('2016-06-20T09:45')
      expect(raw_transaction[:bank_account]).to eql '4164'
      expect(raw_transaction[:amount]).to eql '338'
      expect(raw_transaction[:comment]).to eql 'PortoR221(Porto_R22)'
    end

    it 'should parse income email' do
      mail = Mail.new do
        body %(
!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= -338UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
)
      end
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:type]).to eql PendingTransaction::INCOME_TYPE_ID
      expect(raw_transaction[:amount]).to eql '338'
    end

    it 'should handle decimal amount' do
      mail = Mail.new do
        body %(
!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= 338.43UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
)
      end
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:amount]).to eql '338.43'
      mail = Mail.new do
        body [
          '!uvedomlenie!',
          'Data:20/06 09:45',
          'Karta:*4164',
          'Summa= -338.43UAH(Uspeshno)',
          'Balans= 19899.79UAH',
          'Mesto:PortoR221(Porto_R22)'
        ].join("\n")
      end
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:amount]).to eql '338.43'
    end

    it 'should fail if start pattern not found' do
      mail = Mail.new do
        body %(Data:20/06 09:45)
      end
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Start pattern not found')
    end

    it 'should fail if expected attributes not found' do
      valid_body_lines = [
        '!uvedomlenie!',
        'Data:20/06 09:45',
        'Karta:*4164',
        'Summa= -338.43UAH(Uspeshno)',
        'Balans= 19899.79UAH',
        'Mesto:PortoR221(Porto_R22)'
      ]

      invalid_body = valid_body_lines.dup
      invalid_body.delete_at(1)
      mail = Mail.new { body invalid_body.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Data: pattern not found')

      invalid_body = valid_body_lines.dup
      invalid_body.delete_at(2)
      mail = Mail.new { body invalid_body.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Karta:* pattern not found')

      invalid_body = valid_body_lines.dup
      invalid_body.delete_at(3)
      mail = Mail.new { body invalid_body.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Summa= pattern not found')

      invalid_body = valid_body_lines.dup
      invalid_body.delete_at(4)
      mail = Mail.new { body invalid_body.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Balans= pattern not found')

      invalid_body = valid_body_lines.dup
      invalid_body[5] = 'invalid'
      mail = Mail.new { body invalid_body.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Mesto: pattern not found')
    end

    it 'should fail Summa has unexpected format' do
      body_lines = [
        '!uvedomlenie!',
        'Data:20/06 09:45',
        'Karta:*4164',
        'Summa= -338.43(Uspeshno)',
        'Balans= 19899.79UAH',
        'Mesto:PortoR221(Porto_R22)'
      ]
      mail = Mail.new { body body_lines.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Summa value has unexpected format')
    end

    it 'should fail Balans has unexpected format' do
      body_lines = [
        '!uvedomlenie!',
        'Data:20/06 09:45',
        'Karta:*4164',
        'Summa= -338.43UAH(Uspeshno)',
        'Balans= 19899.79',
        'Mesto:PortoR221(Porto_R22)'
      ]
      mail = Mail.new { body body_lines.join("\n") }
      expect { subject.parse_email mail }.to raise_error(EmailParser::ParserError, 'Balans value has unexpected format')
    end

    it 'should include currency in the comment if it was different from balans' do
      body_lines = [
        '!uvedomlenie!',
        'Data:20/06 09:45',
        'Karta:*4164',
        'Summa= -338.43EUR(Uspeshno)',
        'Balans= 19899.79UAH',
        'Mesto:PortoR221(Porto_R22)'
      ]
      mail = Mail.new { body body_lines.join("\n") }
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:comment]).to eql('Amount is EUR. Balance 19899.79UAH. PortoR221(Porto_R22)')
    end
  end
end
