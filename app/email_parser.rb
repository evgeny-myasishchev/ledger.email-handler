require 'digest'
require 'base64'

module EmailParser
  class ParserError < StandardError; end

  #
  # Parse mail
  # Return hash with a following structure:
  # - id
  # - amount
  # - date
  # - comment
  # - bank_account
  # - type_id
  #
  def self.parse_email(bic, mail)
    # TODO: Assign transactionid from messageId (probably make hash of it)
    begin
      require "app/email_parser/#{bic}"
    rescue LoadError
      raise ParserError, "Can not find parser for bic: #{bic}"
    end
    parser = EmailParser.const_get bic
    transaction = parser.parse_email mail
    transaction[:id] = Base64.urlsafe_encode64 Digest::SHA256.digest mail['Message-ID'].to_s
    transaction
  end
end
