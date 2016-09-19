require 'mail'
require 'app/email_parser'
require 'app/email_parser/PBANUA2X'

describe EmailParser::PBANUA2X do
  subject { described_class }

  def fake_bank_account
    "#{SecureRandom.random_number(10)}*#{SecureRandom.random_number(100).to_s.rjust(2, '0')}"
  end

  describe 'parse_email' do
    it 'should parse expense transaction' do
      date = DateTime.parse FFaker::Time.datetime(hours: 23, minuts: 32)

      currency = fake_currency
      amount = fake_amount
      description = 'Аптека Аптека Класc'
      account = fake_bank_account
      time = date.strftime('%H:%M')
      mail = Mail.new do
        date date.iso8601
        body %(
#{amount}#{currency} #{description} #{account} #{time} Бал. 1824.88UAH Бал. Бонус+ 135.40UAH
Lorem ipsum dolor sit amet
)
      end
      raw_transaction = subject.parse_email mail
      expect(raw_transaction[:type_id]).to eql PendingTransaction::EXPENSE_TYPE_ID
      expect(raw_transaction[:date].iso8601).to eql date.iso8601
      expect(raw_transaction[:bank_account]).to eql account
      expect(raw_transaction[:amount]).to eql amount
      expect(raw_transaction[:comment]).to eql description
    end

    it 'should raise error if has no leading amount' do
      mail = Mail.new('Message-ID' => fake_string('MSG-ID')) do
        body %(
3324432 Ресторан Феличе 4*32 20:59 Бал. 677.94UAH Бал. Бонус+ 135.40UAH
Lorem ipsum dolor sit amet
)
      end

      expect { subject.parse_email(mail) }.to raise_error EmailParser::ParserError, "Leading amount not found. MailId: #{mail['Message-ID']}"
    end

    it 'should raise error if account not found' do
      mail = Mail.new('Message-ID' => fake_string('MSG-ID')) do
        body %(
294.00UAH Ресторан Феличе 33443 20:59 Бал. 677.94UAH Бал. Бонус+ 135.40UAH
Lorem ipsum dolor sit amet
)
      end

      expect { subject.parse_email(mail) }.to raise_error EmailParser::ParserError, "Account not found. MailId: #{mail['Message-ID']}"
    end

    it 'should raise error if time not found' do
      mail = Mail.new('Message-ID' => fake_string('MSG-ID')) do
        body %(
294.00UAH Ресторан Феличе 3*43 22-56 Бал. 677.94UAH Бал. Бонус+ 135.40UAH
Lorem ipsum dolor sit amet
)
      end

      expect { subject.parse_email(mail) }.to raise_error EmailParser::ParserError, "Time not found. MailId: #{mail['Message-ID']}"
    end
  end
end
