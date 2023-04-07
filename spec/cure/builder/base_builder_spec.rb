# frozen_string_literal: true

require "cure/builder/base_builder"

RSpec.describe Cure::Builder::BaseBuilder do
  describe "#process" do
    it "will raise if called on base" do
      expect { Cure::Builder::BaseBuilder.new("_default", "x", {}).process }.to raise_error
    end
  end
end

RSpec.describe Cure::Builder::AddBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate column: "Tags" do
          explode options: { keep_existing: false }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "new", {default_value: "abc"})
      builder.process

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({_id: 1, col_index: "1", json: "{\"abc\": \"def\",\"def\": 123}", new: "abc"})
      expect(results[1]).to eq({_id: 2, col_index: "2", json: "{\"abc\": \"def\",\"ghi\": 123}", new: "abc"})
    end
  end
end

RSpec.describe Cure::Builder::RemoveBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate column: "Tags" do
          explode options: { keep_existing: false }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "json", {})
      builder.process

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({_id: 1, col_index: "1"})
      expect(results[1]).to eq({_id: 2, col_index: "2"})
    end
  end
end

RSpec.describe Cure::Builder::RenameBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate column: "Tags" do
          explode options: { keep_existing: false }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "col_index", {"new_name" => "new"})
      builder.process

      results = []

      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({_id: 1, json: "{\"abc\": \"def\",\"def\": 123}", new: "1"})
      expect(results[1]).to eq({_id: 2, json: "{\"abc\": \"def\",\"ghi\": 123}", new: "2"})
    end
  end
end

RSpec.describe Cure::Builder::CopyBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate column: "Tags" do
          explode options: { keep_existing: false }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "col_index", {"to_column" => "abc"})
      builder.process

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({abc: "1", col_index: "1", _id: 1, json: "{\"abc\": \"def\",\"def\": 123}"})
      expect(results[1]).to eq({abc: "2", col_index: "2", _id: 2, json: "{\"abc\": \"def\",\"ghi\": 123}"})
    end
  end
end

RSpec.describe Cure::Builder::WhitelistBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate do
          whitelist options: { columns: ["col_index"] }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", nil, {columns: ["col_index"]})
      builder.process

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({col_index: "1", _id: 1})
      expect(results[1]).to eq({col_index: "2", _id: 2})
    end
  end
end

RSpec.describe Cure::Builder::BlacklistBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate do
          blacklist options: { columns: ["json"] }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#process" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", nil, {columns: ["json"]})
      builder.process

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(results[0]).to eq({col_index: "1", _id: 1})
      expect(results[1]).to eq({col_index: "2", _id: 2})
    end
  end
end

# RSpec.describe Cure::Builder::ExplodeBuilder do
#   before :all do
#     @source_file_loc = "spec/cure/test_files/explode_csv.csv"
#     template_file_loc = "../../../spec/cure/test_files/explode_template.json"
#
#     Cure::Launcher.new
#               .with_csv_file(:pathname, Pathname.new(@source_file_loc))
#               .with_template(:file, Pathname.new(template_file_loc))
#               .setup
#
#     @coordinator = Cure::Coordinator.new
#   end
#
#   describe "#process" do
#     it "will extract required sections" do
#       @coordinator.send(:extract)
#
#       opts = {
#         "build" => {
#           "candidates" => [
#             {
#               "column" => "json",
#               "action" => {
#                 "name" => "explode",
#                 "options" => {
#                   "keep_existing" => false
#                 }
#               }
#             }
#           ]
#         }
#       }
#
#       exploder = Cure::Builder::ExplodeBuilder.new(
#         "_default",
#         opts["build"]["candidates"][0]["column"],
#         opts["build"]["candidates"][0]["action"]["options"]
#       )
#
#       result = exploder.process
#
#       expect(exploder.safe_parse_json("dfsdfd")).to eq({})
#
#       expect(result.content["_default"].column_headers.keys).to eq(%w[col_index json abc def ghi])
#       expect(result.content["_default"].rows[0]).to eq(["1", "{\"abc\": \"def\",\"def\": 123}", "def", 123, ""])
#       expect(result.content["_default"].rows[1]).to eq(["2", "{\"abc\": \"def\",\"ghi\": 123}", "def", "", 123])
#     end
#   end
# end
