module EmailParser
  class ParserError < StandardError; end

  #
  # Parse mail
  # Return hash with a following structure:
  # - id
  # - type
  # - bank_account
  # - amount
  # - date
  # - comment
  #
  def self.parse_email(bic, mail)
    # TODO: Assign transactionid from messageId (probably make hash of it)
    begin
      require "app/email-parser/#{bic}"
    rescue LoadError
      raise ParserError, "Can not find parser for bic: #{bic}"
    end
    parser = EmailParser.const_get bic
    transaction = parser.parse_email mail
    transaction[:id] = mail['Message-ID'].to_s
    transaction
  end
end
