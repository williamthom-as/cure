# frozen_string_literal: true

require "cure/transformation/candidate"
require "cure/generator/base_generator"
require "cure/strategy/base_strategy"

RSpec.describe Cure::Transformation::Candidate do # rubocop:disable Metrics/BlockLength
  config = %(
    {
      "column" : "bill/PayerAccountId",
      "translations" : [{
        "strategy" : {
          "name": "full",
          "options" : {}
        },
        "generator" : {
          "name" : "number",
          "options" : {
            "length" : 12
          }
        },
        "no_match_translation" : {
          "strategy" : {
            "name": "full",
            "options" : {}
          },
          "generator" : {
            "name" : "guid",
            "options" : {
              "length" : 24
            }
          }
        }
     }]
    }
  )

  describe "#new" do
    it "should load a candidate" do
      candidate = Cure::Transformation::Candidate.new.from_json(config)
      expect(candidate.translations.first.class).to eq(Cure::Transformation::Translation)
      expect(candidate.translations.first.strategy.class).to eq(Cure::Strategy::FullStrategy)
      expect(candidate.translations.first.generator.class).to eq(Cure::Generator::NumberGenerator)
    end

    it "it should look up in history if it exists" do
      candidate = Cure::Transformation::Candidate.new.from_json(config)
      val = candidate.perform("abc")
      val_two = candidate.perform("abc")
      expect(val).to eq(val_two)
    end

    it "strategy length should match the options" do
      candidate = Cure::Transformation::Candidate.new.from_json(config)
      val = candidate.perform("xxk")
      expect(val.to_s.length).to eq(candidate.translations.first.generator.options["length"].to_i)
    end
  end

  regex_config = %(
    {
      "column" : "lineItem/ResourceId",
      "no_match_translation" : {
        "strategy" : {
          "name": "full",
          "options" : {}
        },
        "generator" : {
          "name" : "guid",
          "options" : {
            "length" : 24
          }
        }
      },
      "translations" : [{
        "strategy" : {
          "name": "regex",
          "options" : {
            "regex_cg" : "^arn:aws:.*:(.*):.*$"
          }
        },
        "generator" : {
          "name" : "number",
          "options" : {
            "length" : 12
          }
        }
     },{
        "strategy" : {
          "name": "regex",
          "options" : {
            "regex_cg" : "^.*:.*\/(.*)$"
          }
        },
        "generator" : {
          "name" : "guid",
          "options" : {
            "length" : 48
          }
        }
     },{
        "strategy" : {
          "name": "regex",
          "options" : {
            "regex_cg" : "^i-(.*)"
          }
        },
        "generator" : {
          "name" : "number",
          "options" : {
            "length" : 12
          }
        }
     }]
    }
  )

  describe "#extract" do
    it "it should look up in history if it exists" do
      candidate = Cure::Transformation::Candidate.new.from_json(regex_config)
      val = candidate.perform("arn:aws:kms:ap-southeast-2:111111111111:key/e8192ac9-1111-1111-1111-42f9b7e18937")
      val_two = candidate.perform("arn:aws:kms:ap-southeast-2:111111111111:key/e8192ac9-1111-1111-1111-42f9b7e18937")
      val_three = candidate.perform("i-11111111")
      val_four = candidate.perform("ABCNOMATCHFORME")

      expect(val).to eq(val_two)
      expect(val_three).to_not eq("i-11111111")
      expect(val_four.length).to eq(36)
    end
  end
end
