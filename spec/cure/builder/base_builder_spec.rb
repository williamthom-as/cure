# frozen_string_literal: true

require "cure/builder/base_builder"

RSpec.describe Cure::Builder::BaseBuilder do
  describe "#call" do
    it "will raise if called on base" do
      builder = Cure::Builder::BaseBuilder.new("_default", "x", {})
      expect(builder.to_s).to eq("Base Builder")

      expect { builder.call }.to raise_error(
        NotImplementedError,
        "Cure::Builder::BaseBuilder has not implemented method 'call'"
      )
    end
  end
end

RSpec.describe Cure::Builder::AddBuilder do
  before :all do
    @source_file_loc = "spec/cure/test_files/explode_csv.csv"

    main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(@source_file_loc))
    main.with_config do
      build do
        candidate column: "new" do
          add options: { default_value: "-" }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "new", {default_value: "abc"})
      builder.call

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Add Builder")
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
        candidate column: "json" do
          remove options: { keep_existing: false }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "json", {})
      builder.call

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Remove Builder")
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
          rename options: { new_name: "test" }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "col_index", {"new_name" => "new"})
      builder.call

      results = []

      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Rename Builder")
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
        candidate column: "col_index" do
          copy options: { options: { to_column: "abc" } }
        end
      end
    end

    main.setup

    @coordinator = Cure::Coordinator.new
  end

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", "col_index", {to_column: "abc"})
      builder.call

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Copy Builder")
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

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", nil, {columns: ["col_index"]})
      builder.call

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Whitelist Builder")
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

  describe "#call" do
    it "will extract required sections" do
      @coordinator.send(:extract)

      builder = described_class.new("_default", nil, {columns: ["json"]})
      builder.call

      results = []
      builder.with_database do |db_svc|
        db_svc.with_paged_result(:_default) do |row|
          results << row
        end
      end

      expect(builder.to_s).to eq("Blacklist Builder")
      expect(results[0]).to eq({col_index: "1", _id: 1})
      expect(results[1]).to eq({col_index: "2", _id: 2})
    end
  end
end
