require "rails_helper"

RSpec.describe ClientConfig, type: :model do
    let(:valid_attributes) do
        {
            name: "Test Client",
            client_id: "test_client_123",
            redirect_uri: "http://localhost:3000/callback"
        }
    end

    describe 'validations' do
        context 'with valid attributes' do
            it 'is valid' do
                client_config = ClientConfig.new(valid_attributes)
                expect(client_config).to be_valid
            end
        end

        context 'with invalid attributes' do
            context 'when name is missing' do
                it 'is not valid' do
                    attrs = valid_attributes.except(:name)
                    client_config = ClientConfig.new(attrs)
                    expect(client_config).not_to be_valid
                end
            end

            context 'when client_id is missing' do
                it 'is not valid' do
                    attrs = valid_attributes.except(:client_id)
                    client_config = ClientConfig.new(attrs)
                    expect(client_config).not_to be_valid
                end
            end

            context 'when client_id is not unique' do
                it 'is not valid' do
                    ClientConfig.create!(valid_attributes)
                    duplicate_attrs = valid_attributes.dup
                    client_config = ClientConfig.new(duplicate_attrs)
                    expect(client_config).not_to be_valid
                end
            end

            context 'when redirect_uri is missing' do
                it 'is not valid' do
                    attrs = valid_attributes.except(:redirect_uri)
                    client_config = ClientConfig.new(attrs)
                    expect(client_config).not_to be_valid
                end
            end
        end
    end