module EmailParser
  class AgricoleParser
    AMOUNT_REGEX = /^(?<type>-?)(?<amount>\d+(\.\d+)?)(?<currency>[a-zA-Z]{3})(?<status>.*)$/
    class << self
      def parse_email(mail)
        body = mail.body.to_s
        offset = body.index('!uvedomlenie!')
        raise EmailParser::ParserError, 'Start pattern not found' unless offset
        date, offset = next_data_value(offset, 'Data:', body) do |value|
          DateTime.strptime value, '%d/%m %H:%M'
        end
        bank_account, offset = next_data_value(offset, 'Karta:*', body)
        amount_data, offset = next_data_value(offset, 'Summa=', body) do |value|
          match_data = value.match AMOUNT_REGEX
          raise EmailParser::ParserError, 'Summa value has unexpected format' unless match_data
          {
            amount: match_data[:amount],
            currency: match_data[:currency],
            status: match_data[:status],
            type: match_data[:type]
          }
        end
        balance_data, offset = next_data_value(offset, 'Balans=', body) do |value|
          match_data = value.match AMOUNT_REGEX
          raise EmailParser::ParserError, 'Balans value has unexpected format' unless match_data
          {
            amount: match_data[:amount],
            currency: match_data[:currency],
            value: match_data
          }
        end
        comment, _offset = next_data_value(offset, 'Mesto:', body, line_end: body.length)
        if amount_data[:currency] != balance_data[:currency]
          comment = "Amount is #{amount_data[:currency]}. Balance #{balance_data[:value]}. #{comment}"
        end
        raw_transaction = {
          type: amount_data[:type] == '-' ? PendingTransaction::INCOME_TYPE_ID : PendingTransaction::EXPENSE_TYPE_ID,
          date: date,
          bank_account: bank_account,
          amount: amount_data[:amount],
          comment: comment
        }
        raw_transaction
      end

      private

      def next_data_value(start_at, token, body, line_end: nil)
        token_start = body.index(token, start_at)
        raise EmailParser::ParserError, "#{token} pattern not found" unless token_start
        line_end ||= body.index("\n", token_start)
        raw_value = body[token_start + token.length..line_end].strip
        value = block_given? ? yield(raw_value) : raw_value
        [value, line_end]
      end
    end
  end
end
