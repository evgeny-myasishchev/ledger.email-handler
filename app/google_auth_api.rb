require 'app/lib/request'

class GoogleAuthApi
  Log = Logger.get(self)
  class << self
      def get_token(auth_code)
        Log.debug "Getting token for auth_code: #{auth_code}"
        params = {
          code: auth_code,
          client_id: Settings.google.client_id,
          client_secret: Settings.google.client_secret,
          grant_type: 'authorization_code',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
        }

        response = Request.post("#{Settings.google.googleapis_host}/oauth2/v4/token", data: params)
        token = JSON.parse response.body
        Log.debug "Token retrieved for auth_code: #{auth_code}"
        token
      end

      def refresh_token(refresh_token)
        Log.debug 'Refreshing token with a refresh_token...'
        params = {
          refresh_token: refresh_token,
          client_id: Settings.google.client_id,
          client_secret: Settings.google.client_secret,
          grant_type: 'refresh_token'
        }

        response = Request.post("#{Settings.google.googleapis_host}/oauth2/v4/token", data: params)
        token = JSON.parse response.body
        Log.debug 'Token refreshed'
        token
      end
  end
end
