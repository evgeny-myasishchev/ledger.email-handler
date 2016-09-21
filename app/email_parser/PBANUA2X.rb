module EmailParser
  class PBANUA2X < BaseParser
    class << self
      INCOME_PATTERN = /^Поповнення$/
      BASE_AMOUNT_PATTERN = '(?<value>\\d+\.\\d{2})(?<currency>\\w{3})'.freeze
      AMOUNT_PATTERN = Regexp.compile("^#{BASE_AMOUNT_PATTERN}")
      BALANCE_PATTERN = Regexp.compile("^Бал. #{BASE_AMOUNT_PATTERN}")

      def parse_email(mail)
        body = extract_body mail
        amount_match = body.match(AMOUNT_PATTERN)
        raise_parser_error(mail, 'Leading amount not found') unless amount_match

        bank_account_match = amount_match.post_match.match(/\d\*\d{2}/)
        raise_parser_error(mail, 'Account not found') unless bank_account_match

        comment = amount_match.post_match[0, bank_account_match.begin(0)].strip

        time_match = bank_account_match.post_match.match(/^\s\d{2}:\d{2}/)
        raise_parser_error(mail, 'Time not found') unless time_match

        date = DateTime.iso8601 mail.date.strftime("%FT#{time_match.to_s.strip}:00%:z")

        # if balance currency is different then payment was in different currency
        balance_match = time_match.post_match.lstrip.match(BALANCE_PATTERN)
        raise_parser_error(mail, 'Balance not found') unless balance_match
        # if balance_match[:currency] != amount_match[:currency]
        #   puts '==hello'
        # end

        type_id = PendingTransaction::EXPENSE_TYPE_ID
        type_id = PendingTransaction::INCOME_TYPE_ID if comment.index(INCOME_PATTERN)

        build_raw_transaction amount_match[:value], date, bank_account_match.to_s, comment.to_s, type_id
      end

      def build_raw_transaction(amount, date, bank_account, comment, type_id)
        {
          amount: amount,
          date: date,
          comment: comment,
          bank_account: bank_account,
          type_id: type_id
        }
      end

      private

      def raise_parser_error(mail, msg)
        raise EmailParser::ParserError, "#{msg}. MailId: #{mail['Message-ID']}"
      end
    end
  end
end
