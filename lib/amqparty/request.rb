require 'pry'
module AMQParty
  class UnsupportedURIScheme < StandardError; end

  class Request < HTTParty::Request
    def perform(&block)
      unless %w{amqp amqps}.include? uri.scheme.downcase
        raise UnsupportedURIScheme, "#{uri.scheme} must be amqp or amqps"
      end
      validate
      setup_raw_request
      chunked_body = nil

      ssl = uri.scheme.downcase == "amqps" ? true : false
      path = uri.path[1..-1]
      connection_options = {host: uri.host, ssl: ssl}
      connection_options[:user] = uri.user if uri.user
      connection_options[:password] = uri.password if uri.password
      #binding.pry
      Rack::AMQP::Client.with_client(connection_options) do |client|
        Timeout.timeout(10) do
          method_name = http_method.name.split(/::/).last.upcase
          body = options[:body] || ""
          body = HTTParty::HashConversions.to_params(options[:body]) if body.is_a?(Hash)
          headers = options[:headers] || {}
          response = client.request(path, {body: body, http_method: method_name, headers: headers, timeout: 5})
          klass = Net::HTTPResponse.send(:response_class,response.response_code.to_s)
          http_response = klass.new("1.1", response.response_code, "Found")
          response.headers.each_pair do |key, value|
            http_response.add_field key, value
          end
          http_response.body = response.payload
          http_response.send(:instance_eval, "def body; @body; end") # TODO GIANT HACK
          self.last_response = http_response
        end
      end

      handle_deflation unless http_method == Net::HTTP::Head
      handle_response(chunked_body, &block)
    end
  end
end
