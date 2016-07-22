require 'mail'
require 'app/email_parser'
require 'app/email-parser/AGRIUAUK'

describe EmailParser::AgricoleParser do
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
        body %(
!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= -338.43UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
)
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

    xit 'should fail if expected attributes not found' do
    end

    xit 'should fail Summa has unexpected format' do
    end

    xit 'should fail Summa Balans has unexpected format' do
    end

    xit 'should include currency in the comment if it was different from balans' do
    end
  end
end
