require 'rest-client'

class GoogleAuthApi
  class << self
      def get_token(auth_code)
        params = {
          code: auth_code,
          client_id: Settings.google.client_id,
          client_secret: Settings.google.client_secret,
          grant_type: 'authorization_code',
          redirect_uri: 'urn:ietf:wg:oauth:2.0:oob'
        }

        response = RestClient.post("#{Settings.google.googleapis_host}/oauth2/v4/token", params, &method(:handle_request))
        JSON.parse response.body
      end

      private def handle_request(resp, req, result, &block)
        # TODO: Log response
        resp.return! req, result, &block
      end
  end
end
