require_relative '../spec_helper.rb'

describe Role do
  role_factory = FactoryGirl.factories.find(:role)
  role_traits = role_factory.defined_traits.map(&:name)

  role_traits.each {|trait| let!(trait) { create(:role, trait) } }

  it 'Admin has the lowest rank (having most permissions)' do
    expect(Role.find_by('rank = ?', Role.minimum(:rank))).to eq admin
  end

  it 'Nologin has the highest rank (having least permissions)' do
    expect(Role.find_by('rank = ?', Role.maximum(:rank))).to eq nologin
  end
end
