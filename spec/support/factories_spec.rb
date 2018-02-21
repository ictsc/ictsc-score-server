# https://github.com/thoughtbot/factory_bot/wiki/Testing-all-Factories-(with-RSpec)
RSpec.describe "Factory Girl" do
  FactoryBot.factories.map(&:name).each do |factory_name|
    describe "#{factory_name} factory" do

      # Test each factory
      it "is valid" do
        factory = FactoryBot.build(factory_name)
        if factory.respond_to?(:valid?)
          expect(factory).to be_valid, lambda { factory.errors.full_messages.join("\n") }
        end
      end

      # Test each trait
      FactoryBot.factories[factory_name].definition.defined_traits.map(&:name).each do |trait_name|
        context "with trait #{trait_name}" do
          it "is valid" do
            factory = FactoryBot.build(factory_name, trait_name)
            if factory.respond_to?(:valid?)
              expect(factory).to be_valid, lambda { factory.errors.full_messages.join("\n") }
            end
          end
        end
      end
    end
  end
end
