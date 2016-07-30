require 'ffaker'
require 'jwt'
require 'app/pending_transaction'

module FakeFactory
  TRANSACTION_TYPES = [PendingTransaction::INCOME_TYPE_ID, PendingTransaction::EXPENSE_TYPE_ID].freeze

  def build_raw_transaction(bank_account: fake_string('bank-account'))
    {
      id: fake_string('tid'),
      amount: SecureRandom.random_number,
      date: FFaker::Time.date,
      comment: FFaker::Lorem.phrase,
      bank_account: bank_account,
      type_id: TRANSACTION_TYPES[SecureRandom.random_number(TRANSACTION_TYPES.length)]
    }
  end

  def build_pending_transaction
    PendingTransaction.new(
      id: fake_string('tid'),
      amount: SecureRandom.random_number,
      date: FFaker::Time.date,
      comment: FFaker::Lorem.phrase,
      account_id: fake_string('aid'),
      type_id: TRANSACTION_TYPES[SecureRandom.random_number(TRANSACTION_TYPES.length)]
    )
  end

  def fake_access_token(id_token_email: fake_email, id_token_exp: Time.now.to_i + 30)
    id_token_payload = {
      'email' => id_token_email,
      'exp' => id_token_exp
    }

    {
      'access_token' => fake_string('access-token'),
      'token_type' => 'Bearer',
      'expires_in' => 3600,
      'refresh_token' => fake_string('refresh-token'),
      'id_token' => JWT.encode(id_token_payload, nil, 'none')
    }
  end

  def fake_email(name = nil)
    FFaker::Internet.email name
  end

  def fake_string(prefix, length: 10)
    prefix + '-' + FFaker::Lorem.characters[0..length]
  end
end

RSpec.configure do |config|
  config.include FakeFactory
end
