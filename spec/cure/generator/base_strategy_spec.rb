# frozen_string_literal: true

require "cure/generator/imports"
require "cure/transformation/transform"
require "cure/database"

RSpec.describe Cure::Generator::NumberGenerator do
  before :all do
    @number_generator = Cure::Generator::NumberGenerator.new({length: 10 })
  end

  describe "#new" do
    it "should load options" do
      expect(@number_generator.options).to eq({length: 10 })
      expect(@number_generator.describe).to eq(
        "Will create a random list of numbers matching the length of the source string."
      )
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@number_generator.generate(nil, nil).to_s.length).to eq(@number_generator.options[:length])
    end
  end
end

RSpec.describe Cure::Generator::HexGenerator do
  before :all do
    @generator = Cure::Generator::HexGenerator.new({length: 10 })
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({length: 10 })
      expect(@generator.send(:_describe)).to eq(
        "Will create a random list of hex values matching the length of the source string."
      )
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate(nil, nil).to_s.length).to eq(@generator.options[:length])
    end
  end
end

RSpec.describe Cure::Generator::RedactGenerator do
  before :all do
    @generator = Cure::Generator::RedactGenerator.new({})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({})
      expect(@generator.send(:_describe)).to eq(
        "Will replace the length of the source string with X."
      )
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate("my_value", nil)).to eq("xxxxxxxx")
      expect(@generator.generate("my_value_2", nil)).to eq("xxxxxxxxxx")
    end
  end
end

RSpec.describe Cure::Generator::GuidGenerator do
  before :all do
    @generator = Cure::Generator::GuidGenerator.new({})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({})
      expect(@generator.send(:_describe)).to eq(
        "Will create a random GUID."
      )
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate(nil, nil).to_s.length).to eq(36)
    end
  end
end

RSpec.describe Cure::Generator::BaseGenerator do
  before :all do
    @generator = Cure::Generator::BaseGenerator.new({})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({})
      expect { @generator.describe }.to raise_error(NotImplementedError)
    end
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect { @generator.generate(nil, nil) }.to raise_error(NotImplementedError)
    end
  end
end

class MockClass
  include Cure::Configuration
  include Cure::Database
end

RSpec.describe Cure::Generator::PlaceholderGenerator do
  before :all do
    @generator = Cure::Generator::PlaceholderGenerator.new({name: "$account_number" })

    template = Cure::Dsl::DslHandler.init do
      transform do
        place_holders({"$account_number" => "123456"})
      end
    end

    template = template.generate
    mc = MockClass.new
    config = mc.create_config("abc", template)
    mc.register_config(config)
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({name: "$account_number" })
      expect(@generator.describe).to eq(
        "Will look up placeholders using '$account_number'. [Set as '123456']"
      )
    end
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect(@generator.generate(nil, nil)).to eq("123456")
    end
  end
end

RSpec.describe Cure::Generator::CharacterGenerator do
  describe "#generate" do
    it "should be 5 if no length provided" do
      generator = Cure::Generator::CharacterGenerator.new({
                                                            types: %w[uppercase lowercase]
                                                          })
      expect(generator.generate(nil, nil).length).to eq(5)
      expect(generator.describe).to eq(
        "Will create a random list of [\"uppercase\", \"lowercase\"] with as many characters as the source string."
      )
    end

    it "should be source length if provided" do
      generator = Cure::Generator::CharacterGenerator.new({
                                                            types: %w[uppercase lowercase]
                                                          })
      expect(generator.generate("abcdefghij", nil).length).to eq(10)
    end

    it "should be config length if provided" do
      generator = Cure::Generator::CharacterGenerator.new({ "length" => 3 })
      expect(generator.generate(nil, nil).length).to eq(3)
    end
  end
end

RSpec.describe Cure::Generator::FakerGenerator do
  describe "#generate" do
    it "should be 5 if no length provided" do
      generator = Cure::Generator::FakerGenerator.new({
                                                        "module" => "Internet",
                                                        "method" => "email"
                                                      })
      expect(generator.generate(nil, nil).include?("@")).to be_truthy
      expect(generator.describe).to eq(
        "Will create a Faker value from [Internet::email]"
      )
    end
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Generator::CaseGenerator do
  describe "#generate" do
    it "match on case" do
      opts = {
        statement: {
          switch: [
            {
              case: "dog",
              return_value: "doggus"
            }, {
              case: "cat",
              return_value: "cattus"
            }
          ],
          else: {
            return_value: "unknown"
          }
        }
      }

      generator = Cure::Generator::CaseGenerator.new(opts)
      expect(generator.generate("dog", nil)).to eq("doggus")
      expect(generator.describe).to eq(
        "Will match source value against a value included in {:switch=>[{:case=>\"dog\", :return_value=>\"doggus\"}, {:case=>\"cat\", :return_value=>\"cattus\"}], :else=>{:return_value=>\"unknown\"}}"
      )
    end

    it "should return else property if no match" do
      opts = {
        statement: {
          switch: [
            {
              case: "dog",
              return_value: "doggus"
            }, {
              case: "cat",
              return_value: "cattus"
            }
          ],
          else: {
            return_value: "unknown"
          }
        }
      }

      generator = Cure::Generator::CaseGenerator.new(opts)
      expect(generator.generate("unknown", nil)).to eq("unknown")
    end

    it "should return nil if no else" do
      opts = {
        statement: {
          switch: [
            {
              case: "dog",
              return_value: "doggus"
            }, {
              case: "cat",
              return_value: "cattus"
            }
          ]
        }
      }

      generator = Cure::Generator::CaseGenerator.new(opts)
      expect(generator.generate("unknown", nil)).to eq(nil)
    end
  end
end
# rubocop:enable Metrics/BlockLength

RSpec.describe Cure::Generator::VariableGenerator do
  before :all do
    @generator = described_class.new({ "name" => "variable" })

    mc = MockClass.new
    mc.init_database
    mc.database_service.create_table(:variables, %w[name value])
    mc.database_service.insert_row(:variables, %w[variable test], columns: %w[name value])
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect(@generator.generate(nil, nil)).to eq("test")
      expect(@generator.describe).to eq(
        "Will look up the variables defined using 'variable'."
      )
    end
  end
end

RSpec.describe Cure::Generator::StaticGenerator do
  before :all do
    @generator = Cure::Generator::StaticGenerator.new({value: "my_val"})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({value: "my_val"})
      expect(@generator.describe).to eq(
        "Will return the defined value [my_val]"
      )
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate(nil, nil).to_s).to eq("my_val")
    end
  end
end

RSpec.describe Cure::Generator::EvalGenerator do
  before :all do
    @generator = Cure::Generator::EvalGenerator.new({eval: "1 + 1"})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({eval: "1 + 1"})
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate(nil, nil)).to eq(2)
    end
  end
end

RSpec.describe Cure::Generator::DeterministicScrambleGenerator do
  before :all do
    @generator = described_class.new({ key: "test", magnitude: :hundredths })
  end

  describe "#generate" do
    it "should generate a replacement" do
      expect(@generator.generate("113.12", nil)).to eq("113.09")
      expect(@generator.describe).to eq("Will deterministically randomise a number.")
    end
  end
end