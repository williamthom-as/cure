# frozen_string_literal: true

module Cure
  class Dispatch

    # @param [Array<Hash>] named_ranges
    attr_accessor :named_ranges

    def initialize
      @named_ranges = [default]
    end

    # @param [Array<String>] hash
    # @return [Cure::Dispatch]
    def self.from_hash(hash)
      this = Cure::Dispatch.new
      this.named_ranges = hash["sections"] if hash.key?("sections")
      this
    end

    def default
      {
        "named_range" => "default",
        "file_name" => "main-file",
        "type" => "csv"
      }
    end
  end
end
