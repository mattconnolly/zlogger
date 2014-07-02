require 'spec_helper'
require 'timeout'

describe Zlogger::Client do

  context "Stubbed ZMQ" do
    let(:socket) { double("zmq socket") }
    let(:zmq_context) { double("zmq context", :socket => socket) }
    before do
      ZMQ.stub(:context => zmq_context)
      Zlogger::Client::LogDevice.any_instance.stub(:run_socket_thread => nil)
    end
    it "logs a message" do
      subject.info "Hello"
      subject.close
      expect(socket).to receive(:connect).with("tcp://127.0.0.1:7000")
      expect(socket).to receive(:send_message) { |message|
        expect(message.size).to eq(2)
        expect(message.popstr).to match(/rspec/)
        expect(message.popstr).to eq("INFO: Hello")
      }
      expect(socket).to receive(:close)
      Timeout.timeout(2) do
        subject.log_device.run_socket_loop
      end
    end
    after do
      subject.close if subject
    end
  end
end
