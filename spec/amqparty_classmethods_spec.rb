require 'spec_helper'

shared_examples_for 'all request methods' do |meth|
  it 'explodes gracefully when missing a protocol' do
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
  end

  describe '#get' do

    it_behaves_like 'all request methods', 'get'

    it 'calls Rack::AMQP::Client with the proper options' do
      # this method is a lot of stubbing, but I guess it's ok?
      fake_with_client = -> {
        fake_client = double()
        fake_client.should_receive(:request).with('test.simple/users.json', {
          body: '',
          http_method: 'GET',
          headers: {},
          timeout: 5
        }) do
          fake_response = double()
          fake_response.stub(:response_code) { 200 }
          fake_response.stub(:headers) { {'response_header' => 'foo'} }
          fake_response.stub(:payload) { 'Hello World' }
          fake_response
        end
        fake_client
      }
      expect(Rack::AMQP::Client).to receive(:client).with({host: 'localhost'}).and_return(&fake_with_client)
      AMQParty.get('amqp://test.simple/users.json')
    end

  end

  it "integrates", brittle: true do
    #pending "Some better way to test integrations"
    Timeout.timeout(3) do
      AMQParty.configure do |c|
        c.amqp_host = 'localhost'
      end
      response = AMQParty.get('amqp://test.simple/users.json')
      expect(response.to_json).to eq("[{\"id\":1,\"login\":\"someguy\",\"password\":\"awesomenesssss\",\"created_at\":\"2013-12-07T17:11:45.518Z\",\"updated_at\":\"2013-12-07T17:11:45.518Z\"},{\"id\":2,\"login\":\"Hi\",\"password\":\"There\",\"created_at\":\"2014-03-30T18:31:21.106Z\",\"updated_at\":\"2014-03-30T18:31:21.106Z\"}]")
    end
  end
end
