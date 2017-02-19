require 'digest'
require 'base64'
require 'nokogiri'

module EmailParser
  class ParserError < StandardError; end

  class BaseParser
    class << self
      protected def extract_body(mail)
        if mail.multipart?
          return mail.text_part.decoded if mail.text_part
          return Nokogiri::HTML(mail.html_part.decoded).text if mail.html_part
          raise "Text or html part not found while parsing message: #{mail['Message-ID']}"
        end

        if mail.content_type && mail.content_type.start_with?('text/html')
          return Nokogiri::HTML(mail.decoded).text
        end

        mail.decoded
      end
    end
  end

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
