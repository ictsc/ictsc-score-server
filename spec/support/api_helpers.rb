require 'rspec'

module ApiHelpers
  def json_response
    JSON.parse(response.body)
  end

  RSpec.shared_examples 'not logged in' do
    it 'returns unauthorized' do
      expect(response.status).to eq 401
    end
  end
end
