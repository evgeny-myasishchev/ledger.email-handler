require 'app/bootstrap'

describe Bootstrap do
  it 'should use pwd as an app_root by default' do
    expect(subject.app_root).to eql(Pathname.new(Dir.pwd))
  end

  it 'should use provided dir as a working directory' do
    expect(described_class.new('tmp').app_root).to eql(Pathname.new('tmp'))
  end

  describe 'create_services' do
    it 'should create services instance' do
      allow(Services).to receive(:new).and_call_original
      services = subject.create_services
      expect(services).to be_an_instance_of Services
      expect(Services).to have_received(:new).with(Pathname.new(Dir.pwd).join('.data'))
    end
  end
end
