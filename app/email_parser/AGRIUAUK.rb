module EmailParser
  class AGRIUAUK < BaseParser
    AMOUNT_REGEX = /^(?<type>-?)(?<amount>\d+(\.\d+)?)(?<currency>[a-zA-Z]{3})(?<status>.*)$/
    class << self
      def parse_email(mail)
        body = extract_body mail
        offset = detect_start body
        date, offset = next_data_value(offset, 'Data:', body) { |value| DateTime.strptime value, '%d/%m %H:%M' }
        bank_account, offset = next_data_value(offset, 'Karta:*', body)
        amount_data, offset = next_data_value(offset, 'Summa=', body, &method(:parse_summa))
        balance_data, offset = next_data_value(offset, 'Balans=', body, &method(:parse_balans))
        comment, _offset = next_data_value(offset, 'Mesto:', body, line_end: body.length)
        build_raw_transaction amount_data, balance_data, date, bank_account, comment
      end

      private

      def detect_start(body)
        offset = body.index('!uvedomlenie!')
        raise EmailParser::ParserError, 'Start pattern not found' unless offset
        offset
      end

      def next_data_value(start_at, token, body, line_end: nil)
        token_start = body.index(token, start_at)
        raise EmailParser::ParserError, "#{token} pattern not found" unless token_start
        line_end ||= body.index("\n", token_start)
        raw_value = body[token_start + token.length..line_end].strip
        value = block_given? ? yield(raw_value) : raw_value
        [value, line_end]
      end

      def parse_summa(value)
        match_data = value.match AMOUNT_REGEX
        raise EmailParser::ParserError, 'Summa value has unexpected format' unless match_data

        {
          amount: match_data[:amount],
          currency: match_data[:currency],
          status: match_data[:status],
          type: match_data[:type]
        }
      end

      def parse_balans(value)
        match_data = value.match AMOUNT_REGEX

        raise EmailParser::ParserError, 'Balans value has unexpected format' unless match_data
        {
          amount: match_data[:amount],
          currency: match_data[:currency],
          value: match_data
        }
      end

      def build_raw_transaction(amount_data, balance_data, date, bank_account, comment)
        if amount_data[:currency] != balance_data[:currency]
          comment = "Amount is #{amount_data[:currency]}. Balance #{balance_data[:value]}. #{comment}"
        end

        {
          amount: amount_data[:amount],
          date: date,
          comment: comment,
          bank_account: bank_account,
          type_id: amount_data[:type] == '-' ? PendingTransaction::INCOME_TYPE_ID : PendingTransaction::EXPENSE_TYPE_ID
        }
      end
    end
  end
end
