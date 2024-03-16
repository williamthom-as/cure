# frozen_string_literal: true

module Cure
  class BaseUtility

    # @param [String] source
    # @param [Cure::Transforms::RowCtx] ctx
    def self.call(source, ctx)
      new.call(source, ctx)
    end

    # @param [String] _source
    # @param [Cure::Transforms::RowCtx] _ctx
    def call(_source, _ctx)
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end