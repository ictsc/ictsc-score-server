# RSpec without Rails
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  FactoryBot.find_definitions

  config.before(:suite) do
    DatabaseCleaner.cleaning do
      FactoryBot.lint(verbose: true, traits: true)
    end
  end
end
