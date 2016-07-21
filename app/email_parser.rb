module EmailParser
  #
  # Parse mail
  # Return hash with a following structure:
  # - transactionId
  # - type
  # - bank_account
  # - amount
  # - date
  # - comment
  #
  def self.parse_email(_bic, _mail)
    # TODO: Use BIC specific parser.
    # Assign transactionid from messageId (probably make hash of it)
  end
end
