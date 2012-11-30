require 'spec_helper'

describe QuickbooksWebConnector::SoapWrapper::QBWebConnectorSvcSoap do
  let(:servant) { described_class.new }

  describe 'serverVersion' do
    subject(:response) { servant.serverVersion(stub :parameters) }

    before { QuickbooksWebConnector.configure { |c| c.server_version = '1.2.3' } }

    it { should be_a QuickbooksWebConnector::SoapWrapper::ServerVersionResponse }
    its(:serverVersionResult) { should eq '1.2.3' }

    after { QuickbooksWebConnector.configure { |c| c.server_version = '1.0.0' } }
  end

  describe 'clientVersion' do
    subject(:response) { servant.clientVersion(stub :parameters, strVersion: '2.1.0.30') }

    context 'no minimum version set' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should be_nil }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

    context 'current version passes minimum version check' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = '1.0.0' } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should be_nil }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

    context 'current version fails minimum version check' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = '3.0.0' } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should eq 'E:This version of QuickBooks Web Connector is outdated. Version 3.0.0 or greater is required.' }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

  end

  describe 'authenticate' do
    subject(:response) { servant.authenticate(stub :parameters, strUserName: 'foo', strPassword: 'bar') }

    before { SecureRandom.stub uuid: '71f1f9d9-8012-487c-af33-c84bab4d4ded' }

    it { should be_a QuickbooksWebConnector::SoapWrapper::AuthenticateResponse }

    it 'is a token for future requests' do
      expect(response.authenticateResult[0]).to eq('71f1f9d9-8012-487c-af33-c84bab4d4ded')
    end

    it 'is nil for the valid user, has work, company file field' do
      expect(response.authenticateResult[1]).to be_nil
    end

    it 'is nil for delay' do
      expect(response.authenticateResult[2]).to be_nil
    end

    it 'is nil for the new MinimumRunEveryNSeconds' do
      expect(response.authenticateResult[3]).to be_nil
    end
  end

end
