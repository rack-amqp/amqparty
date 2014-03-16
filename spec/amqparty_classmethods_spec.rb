require 'spec_helper'

shared_examples_for 'all request methods' do |meth|
  it 'and explodes gracefully when missing a protocol' do
    test = -> {
      AMQParty.send(meth, 'test.simple')
    }
    expect(test).to raise_error(AMQParty::UnsupportedURIScheme)
  end
end

describe AMQParty do
  describe '#get' do

    it_behaves_like 'all request methods', 'get'

    it 'calls Rack::AMQP::Client with the proper options' do
      # this method is a lot of stubbing, but I guess it's ok?
      fake_with_client = ->(&block) {
        fake_client = double()
        fake_client.should_receive(:request).with('users.json', {
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
        block.call fake_client
      }
      Rack::AMQP::Client.stub(:with_client, &fake_with_client)
      AMQParty.get('amqp://test.simple/users.json')
    end

  end
end
