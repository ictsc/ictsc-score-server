require "./spec/spec_helper.rb"

describe 'GET / ,' do
#  include Rack::Test::Methods
  
#  def app
#    Sinatra::Application
#  end

  before do
    get '/'
  end

  it '200 OK が返ってくる' do
    expect(response).to be_success
    expect(response.status).to eq(200)
  end

end
