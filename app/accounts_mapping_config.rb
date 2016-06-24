require 'json'

class AccountsMappingConfig
  def initialize(data_dir)
    @config_dir = data_dir.join('accounts-mapping')
  end

  def add_mapping(user_email, bank_account, ledger_account_id)
    FileUtils.mkdir_p @config_dir unless @config_dir.exist?
    target_file = build_target_file user_email
    mapping = if target_file.exist?
                JSON.parse target_file.read
              else
                {}
              end
    mapping[bank_account] = ledger_account_id
    target_file.write JSON.pretty_generate(mapping)
  end

  def get_mappings(user_email)
    target_file = build_target_file(user_email)
    JSON.parse(target_file.read)
  end

  private def build_target_file(email)
    @config_dir.join(email + '.json')
  end
end
