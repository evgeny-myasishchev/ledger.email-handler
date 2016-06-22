class EmailHandlerService
  def initialize(services)
  end

  def process_emails(email, bic, emails_dir)
    # for each email - use parser to parse emails
    # for each parsed transaction build pending transaction
    # Use ledgerApi to submit all pending transactions
  end
end
