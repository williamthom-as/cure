# frozen_string_literal: true
require "json"
require "cure/config"

class MockClass
  include Cure::Configuration
end


RSpec.describe Cure::Configuration do

  describe "#register_config" do
    it "should register config" do
      config = Cure::Configuration::Config.new("abc", {}, "ghi")

      mc = MockClass.new
      mc.register_config(config)

      expect(mc.config.class).to eq(Cure::Configuration::Config)
      expect(mc.config.source_file_location).to eq(config.source_file_location)
      expect(mc.config.template).to eq(config.template)
      expect(mc.config.output_dir).to eq(config.output_dir)
    end
  end
end
