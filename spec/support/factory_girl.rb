# RSpec without Rails
RSpec.configure do |config|
  begin
    DatabaseCleaner.start
    FactoryGirl.lint
  ensure
    DatabaseCleaner.clean
  end

  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    FactoryGirl.find_definitions
  end
end
