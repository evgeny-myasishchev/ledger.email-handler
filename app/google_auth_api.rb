require 'rest-client'

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

        response = RestClient.post("#{Settings.google.googleapis_host}/oauth2/v4/token", params, &method(:handle_request))
        token = JSON.parse response.body
        Log.debug "Token retrieved for auth_code: #{auth_code}"
        token
      end

      private def handle_request(resp, req, result, &block)
        unless result.code == '200'
          Log.error "Request failed with status code: #{result.code}"
          Log.error resp
        end

        # TODO: Log response
        resp.return! req, result, &block
      end
  end
end
