require 'rest-client'

class Request
  Log = Logger.get(self)
  class << self
    def post(url, params)
      RestClient.post(url, params, &method(:handle_request))
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