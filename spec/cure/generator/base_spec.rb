# frozen_string_literal: true

require "cure/generator/base"

RSpec.describe Cure::Generator::NumberGenerator do

  before :all do
    @number_generator = Cure::Generator::NumberGenerator.new({"length" => 10})
  end

  describe "#new" do
    it "should load options" do
      expect(@number_generator.options).to eq({"length" => 10})
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@number_generator.generate.to_s.length).to eq(@number_generator.options["length"])
    end
  end

end

RSpec.describe Cure::Generator::HexGenerator do

  before :all do
    @generator = Cure::Generator::HexGenerator.new({"length" => 10})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({"length" => 10})
    end
  end

  describe "#generate" do
    it "should load options" do
      expect(@generator.generate.to_s.length).to eq(@generator.options["length"])
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
      expect(@generator.generate).to eq("XXX")
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
      expect(@generator.generate.to_s.length).to eq(36)
    end
  end

end

RSpec.describe Cure::Generator::Base do

  before :all do
    @generator = Cure::Generator::Base.new({})
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({})
    end
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect { @generator.generate }.to raise_error(NotImplementedError)
    end
  end

end

class MockClass
  include Cure::Configuration
end

RSpec.describe Cure::Generator::PlaceholderGenerator do

  before :all do
    @generator = Cure::Generator::PlaceholderGenerator.new({"value" => "$account_number"})

    mc = MockClass.new
    config = mc.create_config("abc", {
                                "placeholders" => {
                                  "$account_number" => "123456"
                                }
                              }, "ghi")
    mc.register_config(config)
  end

  describe "#new" do
    it "should load options" do
      expect(@generator.options).to eq({"value" => "$account_number"})
    end
  end

  describe "#generate" do
    it "should raise if called on base class" do
      expect(@generator.generate).to eq("123456")
    end
  end

end