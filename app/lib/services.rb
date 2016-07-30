require 'app/access_token_repository'
require 'app/accounts_mapping_config'
require 'app/email_config'

class Services
  attr_reader :access_token_repo,
              :accounts_mapping_config,
              :email_config
  def initialize(data_dir)
    params = {}
    yield(params) if block_given?
    @access_token_repo = AccessTokenRepository.new data_dir
    @accounts_mapping_config = AccountsMappingConfig.new data_dir
    @email_config = params.fetch(:email_config, EmailConfig::FS.new(data_dir))
  end
end
