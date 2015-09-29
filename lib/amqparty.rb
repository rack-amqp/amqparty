require 'net/http'
require 'httparty'
require 'rack/amqp/client'

module AMQParty

  class << self
    SUPPORTED_HTTP_METHODS = %w{get post put delete head options}
    SUPPORTED_HTTP_METHODS.each do |method|
      eval <<-EOT
        def #{method}(path, options={}, &block)
          perform_request Net::HTTP::#{method.to_s[0...1].upcase}#{method.to_s[1..-1]}, path, options, &block
        end
      EOT
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure(&block)
      yield configuration
    end
  end

  private

    def self.perform_request(http_method, path, options, &block)
      raise AMQParty::UnconfiguredError.new if configuration.amqp_host.nil?

      options = configuration.default_options.dup.merge(options)
      # TODO cookies support
      path = "#{path}/" if path =~ /\Aamqp?:\/\/([^\/])+\Z/
      Request.new(http_method, path, options).perform(&block)
    end

    class Configuration
      attr_accessor :amqp_host
      attr_accessor :port
      attr_accessor :request_timeout
      attr_accessor :tls_ca_certificates
      attr_accessor :verify_peer
      attr_accessor :tls
      attr_accessor :tls_key
      attr_accessor :tls_cert
      attr_accessor :username
      attr_accessor :password
      attr_accessor :heartbeat

      def default_options
        {
          amqp_client_options: {
            host: amqp_host,
            port: port || 5672,
            tls_ca_certificates: tls_ca_certificates || [],
            verify_peer: verify_peer || false,
            tls: tls || false,
            tls_key: tls_key,
            tls_cert: tls_cert,
            username: username || 'guest',
            password: password || 'guest',
            heartbeat: heartbeat || 60
          },
          request_timeout: request_timeout || 5
        }
      end
    end
end

require 'amqparty/version'
require 'amqparty/request'
#require 'amqparty/connection'
