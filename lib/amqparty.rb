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

      options = default_options.dup.merge(options)
      # TODO cookies support
      path = "#{path}/" if path =~ /\Aamqp?:\/\/([^\/])+\Z/
      Request.new(http_method, path, options).perform(&block)
    end

    def self.default_options
      {amqp_client_options: {host: configuration.amqp_host}}
    end

    class Configuration
      attr_accessor :amqp_host
    end
end

require 'amqparty/version'
require 'amqparty/request'
#require 'amqparty/connection'
