require 'mail'
require 'app/email-parser/AGRIUAUK'

describe EmailParser::AgricoleParser do
  subject { described_class }
  describe 'parse_email' do
    it 'should parse expense email' do
      raw_body = <<RAW_MAIL_BODY
Date: Mon, 20 Jun 2016 09:45:40 +0300 (EEST)
From: gsm@credit-agricole.com.ua
To: 380675461301@sms.upc.smpp
Cc: evgmya@gmail.com
Message-ID: <465681514.3559243.1466405140761.JavaMail.apache@pusher.upc.intranet>
Subject:

!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= 338UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
RAW_MAIL_BODY
      mail = Mail.new raw_body
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:type]).to eql PendingTransaction::EXPENSE_TYPE_ID
      expect(raw_transaction[:date]).to eql DateTime.iso8601('2016-06-20T09:45')
      expect(raw_transaction[:bank_account]).to eql '4164'
      expect(raw_transaction[:amount]).to eql '338'
      expect(raw_transaction[:comment]).to eql 'PortoR221(Porto_R22)'
    end

    it 'should parse income email' do
      raw_body = <<RAW_MAIL_BODY
Subject:

!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= -338UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
RAW_MAIL_BODY
      mail = Mail.new raw_body
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:type]).to eql PendingTransaction::INCOME_TYPE_ID
      expect(raw_transaction[:amount]).to eql '338'
    end

    it 'should handle decimal amount' do
      raw_body = <<RAW_MAIL_BODY
Subject:

!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= 338.43UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
RAW_MAIL_BODY
      mail = Mail.new raw_body
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:amount]).to eql '338.43'
      raw_body = <<RAW_MAIL_BODY
Subject:

!uvedomlenie!
Data:20/06 09:45
Karta:*4164
Summa= -338.43UAH(Uspeshno)
Balans= 19899.79UAH
Mesto:PortoR221(Porto_R22)
RAW_MAIL_BODY
      mail = Mail.new raw_body
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:amount]).to eql '338.43'
    end

    xit 'should fail if start pattern not found' do
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
