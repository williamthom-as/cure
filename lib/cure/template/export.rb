# frozen_string_literal: true

module Cure
  class Export

    # @param [Array<String>] named_ranges
    attr_accessor :named_ranges

    def initialize
      @named_ranges = ["default"]
    end

    # @param [Array<String>] hash
    # @return [Cure::Export]
    def self.from_hash(arr)
      this = Cure::Export.new
      this.named_ranges = arr
      this
    end
  end
end
