# frozen_string_literal: true

require "json"
require "cure/helpers/file_helpers"

class MockClass
  include Cure::Helpers::FileHelpers
end

RSpec.describe Cure::Helpers::FileHelpers do
  describe "#with_temp_dir" do
    it "should clean dir by default" do
      mc = MockClass.new
      mc.with_temp_dir("/tmp/cure") do
        mc.with_file("/tmp/cure/abc", "txt") do |file|
          file.write("ABC")
        end

        expect(File.exist?("/tmp/cure/abc.txt")).to be_truthy
      end

      expect(File.exist?("/tmp/cure/abc.txt")).to be_falsey
    end
  end

  describe "#open_file" do
    it "should clean dir by default" do
      mc = MockClass.new
      file = mc.open_file("spec/cure/test_files/test_csv_file.csv")

      expect(file.class).to eq(File)
      expect { mc.open_file("foo.csv") }.to raise_error(RuntimeError, "No file found at [foo.csv]")
    end
  end
end
