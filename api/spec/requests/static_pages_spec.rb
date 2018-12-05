require 'rails_helper'

RSpec.describe "Static pages", type: :request do
  # index page is provided by ui component, outside of this app
  context 'status is 404' do
    let(:response) { get '/' }
    it { expect(response).to be_not_found }
  end
end
