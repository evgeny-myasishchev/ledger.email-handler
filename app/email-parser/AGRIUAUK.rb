class EmailParser
  class AgricoleParser
    AMOUNT_REGEX = /^(?<type>-?)(?<amount>\d+(\.\d+)?)(?<currency>\w{3})(?<status>.*)$/
    class << self
      def parse_email(mail)
        body = mail.body.to_s
        offset = body.index('!uvedomlenie!')
        date, offset = next_data_value(offset, 'Data:', body) do |value|
          DateTime.strptime value, '%d/%m %H:%M'
        end
        bank_account, offset = next_data_value(offset, 'Karta:*', body)
        amount_data, offset = next_data_value(offset, 'Summa=', body) do |value|
          match_data = value.match AMOUNT_REGEX
          {
            amount: match_data[:amount],
            currency: match_data[:currency],
            status: match_data[:status],
            type: match_data[:type]
          }
        end
        balance_data, offset = next_data_value(offset, 'Balans=', body) do |value|
          match_data = value.match AMOUNT_REGEX
          {
            amount: match_data[:amount],
            currency: match_data[:currency]
          }
        end
        comment, offset = next_data_value(offset, 'Mesto:', body)
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

      def next_data_value(start_at, token, body)
        token_start = body.index(token, start_at)
        line_end = body.index("\n", token_start)
        raw_value = body[token_start + token.length..line_end].strip
        value = block_given? ? yield(raw_value) : raw_value
        [value, line_end]
      end
    end
  end
end
