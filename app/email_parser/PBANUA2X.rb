module EmailParser
  class PBANUA2X < BaseParser
    class << self
      INCOME_PATTERN = /^Поповнення$/
      BASE_AMOUNT_PATTERN = '(?<value>\\d+\.\\d{2})(?<currency>\\w{3})'.freeze
      AMOUNT_PATTERN = Regexp.compile("^#{BASE_AMOUNT_PATTERN}")
      BALANCE_PATTERN = Regexp.compile("^Бал.\\s+#{BASE_AMOUNT_PATTERN}")

      def parse_email(mail) # rubocop:disable Metrics/AbcSize
        body = extract_body mail
        amount_match = parse_required(mail, body.lstrip, AMOUNT_PATTERN, 'Leading amount not found')
        bank_account_match = parse_required(mail, amount_match.post_match, /\d\*\d{2}/, 'Account not found')
        time_match = parse_required(mail, bank_account_match.post_match, /^\s\d{2}:\d{2}/, 'Time not found')
        balance_match = parse_required(mail, time_match.post_match.lstrip, BALANCE_PATTERN, 'Balance not found')

        amount = amount_match[:value]
        comment = amount_match.post_match[0, bank_account_match.begin(0)].strip
        type_id = detect_type comment
        date = DateTime.iso8601 mail.date.strftime("%FT#{time_match.to_s.strip}:00%:z")

        # if balance currency is different then payment was in different currency
        if balance_match[:currency] != amount_match[:currency]
          amount, comment_addition = handle_different_currency mail, amount, balance_match, amount_match
          comment += ". #{comment_addition}"
        end

        build_raw_transaction amount, date, bank_account_match.to_s, comment, type_id
      end

      private

      def build_raw_transaction(amount, date, bank_account, comment, type_id)
        {
          amount: amount,
          date: date,
          comment: comment,
          bank_account: bank_account,
          type_id: type_id
        }
      end

      def handle_different_currency(mail, amount, balance_match, amount_match)
        rate_pattern = Regexp.new("Курс (?<value>\\d+\.\\d+) #{balance_match[:currency]}/#{amount_match[:currency]}")
        exchange_rate_match = parse_required(mail, balance_match.post_match.lstrip, rate_pattern, 'Exchange rate not found')

        rate = exchange_rate_match[:value].to_f
        amount = (amount.to_f * rate).round(2)
        [amount, "Actual amount #{amount_match}. #{exchange_rate_match}"]
      end

      def parse_required(mail, data, pattern, error_message)
        next_match = data.match(pattern)
        raise_parser_error(mail, error_message) unless next_match
        next_match
      end

      def detect_type(comment)
        return PendingTransaction::INCOME_TYPE_ID if comment.index(INCOME_PATTERN)
        PendingTransaction::EXPENSE_TYPE_ID
      end

      def raise_parser_error(mail, msg)
        raise EmailParser::ParserError, "#{msg}. MailId: #{mail['Message-ID']}"
      end
    end
  end
end
