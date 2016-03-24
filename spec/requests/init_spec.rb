require_relative "../spec_helper.rb"

describe 'GET / ,' do

  before do
    get '/'
  end

  it '200 OK が返ってくる' do
    expect(last_response).to be_ok
    expect(last_response.status).to eq(200)
  end
end
