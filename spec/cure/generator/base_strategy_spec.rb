# frozen_string_literal: true

require "cure/generator/imports"
require "cure/transformation/transform"
require "cure/database"

RSpec.describe Cure::Generator::NumberGenerator do
  before :all do
    @number_generator = Cure::Generator::NumberGenerator.new({ "length" => 10 })
  end

  describe "#new" do
    it "should load options" do
      expect(@number_generator.options).to eq({ "length" => 10 })
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@number_generator.generate(nil, nil).to_s.length).to eq(@number_generator.options["length"])
    end
  end
end

RSpec.describe Cure::Generator::HexGenerator do
  before :all do
    @generator = Cure::Generator::HexGenerator.new({ "length" => 10 })
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({ "length" => 10 })
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate(nil, nil).to_s.length).to eq(@generator.options["length"])
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
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate("my_value", nil)).to eq("XXXXXXXX")
      expect(@generator.generate("my_value_2", nil)).to eq("XXXXXXXXXX")
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
    @generator = Cure::Generator::PlaceholderGenerator.new({ "name" => "$account_number" })

    conf = {
      "transformations" => {
        "candidates" => [],
        "placeholders" => {
          "$account_number" => "123456"
        }
      }
    }

    template = Cure::Template.from_hash(conf)

    mc = MockClass.new
    config = mc.create_config("abc", template)
    mc.register_config(config)
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({ "name" => "$account_number" })
    end
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect(@generator.generate(nil, nil)).to eq("123456")
    end
  end
end

RSpec.describe Cure::Generator::CharacterGenerator do
  before :all do
  end

  describe "#generate" do
    it "should be 5 if no length provided" do
      generator = Cure::Generator::CharacterGenerator.new({
                                                            "types" => %w[uppercase lowercase]
                                                          })
      expect(generator.generate(nil, nil).length).to eq(5)
    end

    it "should be source length if provided" do
      generator = Cure::Generator::CharacterGenerator.new({
                                                            "types" => %w[uppercase lowercase]
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
    end
  end
end

# rubocop:disable Metrics/BlockLength
RSpec.describe Cure::Generator::CaseGenerator do
  describe "#generate" do
    it "match on case" do
      opts = {
        "statement" => {
          "switch" => [
            {
              "case" => "dog",
              "return_value" => "doggus"
            }, {
              "case" => "cat",
              "return_value" => "cattus"
            }
          ],
          "else" => [
            "return_value" => "unknown"
          ]
        }
      }

      generator = Cure::Generator::CaseGenerator.new(opts)
      expect(generator.generate("dog", nil)).to eq("doggus")
    end

    it "should return else property if no match" do
      opts = {
        "statement" => {
          "switch" => [
            {
              "case" => "dog",
              "return_value" => "doggus"
            }, {
              "case" => "cat",
              "return_value" => "cattus"
            }
          ],
          "else" => {
            "return_value" => "unknown"
          }
        }
      }

      generator = Cure::Generator::CaseGenerator.new(opts)
      expect(generator.generate("unknown", nil)).to eq("unknown")
    end

    it "should return nil if no else" do
      opts = {
        "statement" => {
          "switch" => [
            {
              "case" => "dog",
              "return_value" => "doggus"
            }, {
              "case" => "cat",
              "return_value" => "cattus"
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

    conf = {
      "transformations" => {
        "candidates" => [],
        "placeholders" => {
          "$account_number" => "123456"
        }
      }
    }

    template = Cure::Template.from_hash(conf)

    mc = MockClass.new
    config = mc.create_config("abc", template)
    mc.register_config(config)
    mc.init_database
    mc.database_service.create_table(:variables, %w[name value])
    mc.database_service.insert_row(:variables, %w[1 variable test])
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect(@generator.generate(nil, nil)).to eq("test")
    end
  end
end
