# frozen_string_literal: true
require "json"
require "cure/log"

class MockClass
  include Cure::Log
end


RSpec.describe Cure::Log do

  describe "#log_debug" do
    it "should log" do
      mc = MockClass.new
      expect { mc.log_debug("log_debug") }.to output(/log_debug/).to_stdout_from_any_process
    end
  end

  describe "#log_info" do
    it "should log" do
      mc = MockClass.new
      expect { mc.log_info("log_info") }.to output(/log_info/).to_stdout_from_any_process
    end
  end

  describe "#log_warn" do
    it "should log" do
      mc = MockClass.new
      expect { mc.log_warn("log_warn") }.to output(/log_warn/).to_stdout_from_any_process
    end
  end

  describe "#log_error" do
    it "should log" do
      mc = MockClass.new
      expect { mc.log_error("log_error") }.to output(/log_error/).to_stdout_from_any_process
    end
  end
end
