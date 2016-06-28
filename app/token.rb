class Token
  Log = Logger.get(self)

  class << self
    def refresh_if_needed(token, services)
      id_token = JWT.decode(token['id_token'], nil, false)
      Log.debug('The id_token of user ' + id_token[0]['email'] + ' has not expired yet (leeway is 30 seconds)')
      return token
    rescue JWT::ExpiredSignature
      refresh_token token, services
    end

    private def refresh_token(token, services)
      id_token_payload = JWT.decode(token['id_token'], nil, false, verify_expiration: false)[0]
      email = id_token_payload['email']
      Log.info('The id_token of user ' + email + ' has been expired. Refreshing...')
      refresh_token = token['refresh_token']
      refreshed_token = GoogleAuthApi.refresh_token token['refresh_token']
      refreshed_token['refresh_token'] = refresh_token
      services.access_token_repo.save email, refreshed_token
      Log.info 'Token refreshed'
      refreshed_token
    end
  end
end
