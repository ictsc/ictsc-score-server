# RSpec without Rails
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      # TODO: temporary disable
      FactoryBot.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
