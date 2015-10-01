require 'spec_helper'

shared_examples_for 'all request methods' do |meth|
  it 'explodes gracefully when missing a protocol' do
    binding.pry
    test = -> {
      AMQParty.send(meth, 'test.simple')
    }
    expect(test).to raise_error(AMQParty::UnsupportedURISchemeError)
  end

  it 'blows up when not configured to talk to a amqp broker' do
    AMQParty.instance_variable_set('@configuration', AMQParty::Configuration.new)
    test = -> {
      AMQParty.send(meth, 'amqp://test.simple')
    }
    expect(AMQParty.configuration.amqp_host).to be_nil
    expect(test).to raise_error(AMQParty::UnconfiguredError)
  end
end

describe AMQParty do
  describe '#configure' do
    it "yields a configuration object" do
      x = nil
      AMQParty.configure do |c|
        x = c
      end
      expect(x).to_not be_nil
    end

    it "allows reading the current configuration" do
      expect(AMQParty.configuration).to_not be_nil
    end

    it "allows configuration of the rabbit host" do
      AMQParty.configure do |c|
        c.amqp_host = 'localhost'
      end
      expect(AMQParty.configuration.amqp_host).to eq('localhost')
    end

    it "allows configuration of a request timeout" do
      AMQParty.configure do |c|
        c.request_timeout = 10
      end
      expect(AMQParty.configuration.request_timeout).to eq(10)
    end

  end

  describe '#get' do

    before :each do
      AMQParty.configure do |c|
        c.amqp_host = 'localhost'
        c.request_timeout = 55
      end
    end

    let(:client) { double('Rack::AMQP::Client') }
    let(:params) {
      {
        body: '',
        http_method: 'GET',
        headers: {},
        timeout: 55,
        async: false
      }
    }

    let(:client_params) {
      {
        host: 'localhost',
        port: 5672,
        tls_ca_certificates: [],
        verify_peer: false,
        tls: false,
        tls_key: nil,
        tls_cert: nil,
        username: 'guest',
        password: 'guest',
        heartbeat: 60
      }
    }

    it_behaves_like 'all request methods', 'get'

    it 'calls Rack::AMQP::Client with the proper options' do
      # this method is a lot of stubbing, but I guess it's ok?
      expect(client).to receive(:request).with('test.simple/users.json', params) do
        response = double()
        allow(response).to receive(:response_code) { 200 }
        allow(response).to receive(:headers) { {'response_header' => 'foo'} }
        allow(response).to receive(:payload) { 'Hello World' }
        response
      end

      expect(Rack::AMQP::Client).to receive(:client).with(client_params).and_return(client)
      AMQParty.get('amqp://test.simple/users.json')
    end

    it 'calls Rack::AMQP::Client with the correct path' do
      # this mthod is a lot of stubbing, but I guess it's ok?
      expect(client).to receive(:request).with('test.simple/users.json?login=foo', params) do
        response = double()
        allow(response).to receive(:response_code) { 200 }
        allow(response).to receive(:headers) { {'response_header' => 'foo'} }
        allow(response).to receive(:payload) { 'Hello World' }
        response
      end

      expect(Rack::AMQP::Client).to receive(:client).with(client_params).and_return(client)
      AMQParty.get('amqp://test.simple/users.json?login=foo')
    end

  end

  it "integrates", brittle: true do
    pending "Some better way to test integrations"
    Timeout.timeout(3) do
      AMQParty.configure do |c|
        c.amqp_host = 'localhost'
      end
      response = AMQParty.get('amqp://test.simple/users.json')
      expect(response.to_json).to eq("[{\"id\":1,\"login\":\"someguy\",\"password\":\"awesomenesssss\",\"created_at\":\"2013-12-07T17:11:45.518Z\",\"updated_at\":\"2013-12-07T17:11:45.518Z\"},{\"id\":2,\"login\":\"Hi\",\"password\":\"There\",\"created_at\":\"2014-03-30T18:31:21.106Z\",\"updated_at\":\"2014-03-30T18:31:21.106Z\"}]")
    end
  end
end
