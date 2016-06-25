require 'app/access_token_repository'
require 'app/accounts_mapping_config'

class Services
  attr_reader :access_token_repo,
              :accounts_mapping_config
  def initialize(data_dir)
    @access_token_repo = AccessTokenRepository.new data_dir
    @accounts_mapping_config = AccountsMappingConfig.new data_dir
  end
end
