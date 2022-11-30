# frozen_string_literal: true

module Cure
  class Extraction
    # @return [Extraction::NamedRange] named_ranges
    attr_accessor :named_range

    # @return [Array<Extraction::Variable>] variables
    attr_accessor :variables

    def initialize
      @named_range = NamedRange.new("default", -1, nil)
      @variables = []
    end

    # @param [Hash] hash
    # @return [Cure::Extraction]
    def self.from_hash(hash) # rubocop:disable Metrics/AbcSize
      this = Cure::Extraction.new
      if hash.key? "variables"
        this.variables = hash["variables"].map { |v| Variable.new(v["name"], v["type"], v["location"]) }
      end

      if hash.key?("named_range")
        nr = hash["named_range"]
        this.named_range = NamedRange.new(nr["name"], nr["section"], nr["headers"])
      end

      this
    end

    # We only need to get the named ranges where the candidates have specified
    # interest in them.
    #
    # @param [Array] candidate_nrs
    # @return [Array]
    def required_named_ranges(candidate_nrs)
      return @named_range if candidate_nrs.empty?

      @named_ranges.select { |nr| candidate_nrs.include?(nr.name) }
    end
  end

  # Move to extract/named_range
  class NamedRange

    attr_reader :name, :section, :headers

    # This is complex purely to support headers not being the 0th row.
    # A template can specify that the headers row be completely disconnected
    # from the content, thus we have three bounds:
    # - Content bounds
    # - Header bounds
    # - Sheet bounds (headers AND content)
    def initialize(name, section, headers)
      @name = name
      @section = Extract::CsvLookup.array_position_lookup(section)
      @headers = calculate_headers(headers)
    end

    # @param [Integer] row_idx
    # @return [TrueClass, FalseClass]
    def row_in_bounds?(row_idx)
      row_bounds_range.cover?(row_idx)
    end

    def header_in_bounds?(row_idx)
      header_bounds_range.cover?(row_idx)
    end

    def content_in_bounds?(row_idx)
      content_bounds_range.cover?(row_idx)
    end

    # @return [Range]
    def row_bounds_range
      @row_bounds_range ||= (row_bounds&.first..row_bounds&.last)
    end

    def row_bounds
      # Do this better, memoization makes it hard
      @row_bounds ||= [(content_bounds.concat(header_bounds).uniq.sort)[0],
                       (content_bounds.concat(header_bounds).uniq.sort)[-1]]
    end

    def content_bounds_range
      @content_bounds_range ||= (content_bounds&.first..content_bounds&.last)
    end

    def content_bounds
      @content_bounds ||= @section[2..3]
    end

    def header_bounds_range
      @header_bounds_range ||= (header_bounds&.first..header_bounds&.last)
    end

    def header_bounds
      @header_bounds ||= @headers[2..3]
    end

    private

    def calculate_headers(headers)
      return Extract::CsvLookup.array_position_lookup(headers) if headers

      [@section[0], @section[1], @section[2], @section[2]]
    end

  end

  class Variable
    attr_reader :name, :type, :location

    def initialize(name, type, location)
      @name = name
      @type = type
      @location = [Extract::CsvLookup.position_for_letter(location),
                   Extract::CsvLookup.position_for_digit(location)]
    end

    def row_in_bounds?(row_idx)
      row_bounds_range.cover?(row_idx)
    end

    # @return [Range]
    def row_bounds_range
      @row_bounds_range ||= (@location&.last..@location&.last)
    end

  end
end
