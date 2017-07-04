require 'factory_girl'

FactoryGirl.find_definitions

Role.delete_all
Member.delete_all

%i(nologin admin writer participant viewer).each do |role_trait|
	FactoryGirl.create(:role, role_trait)
end

FactoryGirl.create(:member, :admin, name: 'admin', login: 'admin')
