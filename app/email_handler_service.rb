require 'app/emails_provider'
require 'app/email_parser'
require 'app/token'

class EmailHandlerService
  Log = Logger.get self
  def self.handle_emails(services)
    Log.info 'Handling emails...'

    # For each registered users (user_emails)
    services.email_config.all_email_settings.each do |user_email, email_settings|
      Log.info "Processing user: #{user_email}"

      # Initialize ledger api and prepare mapping config
      account_mappings = services.accounts_mapping_config.get_mappings user_email
      id_token = Token.get_id_token user_email, services
      ledger_api = LedgerApi.create id_token

      # For each registered email settings of the user
      email_settings.each do |bic, provider_settings|
        Log.debug "Processing bic #{bic}"
        emails_provider = EmailsProvider.create provider_settings

        # Parse and submit each email to ledger
        emails_provider.each do |email|
          Log.debug "Processing email id=#{email['Message-ID']}"
          raw_transaction = EmailParser.parse_email bic, email
          pending_transaction = PendingTransaction.build account_mappings, raw_transaction
          Log.debug "Submitting pending transaction to ledger: #{pending_transaction}"
          ledger_api.report_pending_transaction pending_transaction

          # TODO: Extend provider to remove email
        end
      end
    end
    Log.info 'Emails handled.'
  end
end
