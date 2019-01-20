require 'factory_bot'

FactoryBot.find_definitions

%i(nologin admin writer participant viewer).each {|role_trait| FactoryBot.create(:role, role_trait) }
FactoryBot.create(:member, :admin, name: 'admin', login: 'admin')
