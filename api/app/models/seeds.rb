require 'factory_bot'

FactoryBot.find_definitions

Role.delete_all
Member.delete_all

%i(nologin admin writer participant viewer).each do |role_trait|
  FactoryBot.create(:role, role_trait)
end

FactoryBot.create(:member, :admin, name: 'admin', login: 'admin')
