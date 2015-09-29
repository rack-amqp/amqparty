module AMQParty
  class AMQPartyError < StandardError; end
  class UnsupportedURISchemeError < AMQPartyError; end
  class UnconfiguredError < AMQPartyError; end
  HTTParty::Request::SupportedURISchemes = ['amqp', 'amqps']

  class Request < HTTParty::Request
    def perform(&block)
      unless %w{amqp}.include? uri.scheme.to_s.downcase
        raise UnsupportedURISchemeError, "#{uri.scheme} must be amqp"
      end
      validate
      setup_raw_request
      chunked_body = nil

      path = "#{uri.host}#{uri.path}"
      path = "#{path}?#{uri.query}" if uri.query
      connection_options = options[:amqp_client_options]
      async              = options[:async]

      Rack::AMQP::Client.with_client(connection_options) do |client|
        method_name = http_method.name.split(/::/).last.upcase
        body = options[:body] || ""

        if body.is_a?(Hash)
          body = HTTParty::HashConversions.to_params(options[:body])
        end

        headers = options[:headers] || {}
        timeout = options[:request_timeout]

        response = client.request(path, {
            body: body,
            http_method: method_name,
            headers: headers,
            timeout: timeout,
            async: !!async
          }
        )

        response_code = response.response_code
        klass = Net::HTTPResponse.send(:response_class, response_code.to_s)
        http_response = klass.new("1.1", response_code, "Found")
        response.headers.each_pair do |key, value|
          http_response.add_field key, value
        end
        http_response.body = response.payload
        
        # TODO GIANT HACK
        http_response.send(:instance_eval, "def body; @body; end")
        self.last_response = http_response
      end

      handle_deflation unless http_method == Net::HTTP::Head
      handle_response(chunked_body, &block)
    end
  end
end
