# frozen_string_literal: true

require "json"
require "fileutils"
require "cure/config"

RSpec.describe Cure::Launcher do
  describe "#init" do
    it "should set up the main service" do
      source_file_loc = "spec/cure/test_files/test_csv_file.csv"

      main = Cure::Launcher.new.with_csv_file(:pathname, Pathname.new(source_file_loc))
      main.with_config {}
      main.setup

      config = main.config
      expect(config.source_files[0].class).to eq(Cure::Configuration::CsvFileProxy)
      expect(config.template.class).to eq(Cure::Dsl::Template)
    end
  end
end

RSpec.describe Cure::Configuration::CsvFileProxy do
  describe ".load_file" do
    it "should give me a file handler for file" do
      file = File.open("spec/cure/test_files/test_csv_file.csv")

      handler = Cure::Configuration::CsvFileProxy.load_file(:file, file, "file")
      expect(handler.csv_handler.class).to eq(Cure::Configuration::FileHandler)
      expect(handler.csv_handler.type).to eq(:file)
      expect(handler.csv_handler.description).to eq("test_csv_file.csv")

      handler.with_file do |fyle, ref_name|
        expect(ref_name).to eq("file")
        expect(fyle.class).to eq(File)
      end
    end

    it "should give me a file handler for file contents" do
      file = "file_contents,are_here"

      handler = Cure::Configuration::CsvFileProxy.load_file(:file_contents, file, "file contents")
      expect(handler.csv_handler.class).to eq(Cure::Configuration::FileContentsHandler)
      expect(handler.csv_handler.type).to eq(:file_contents)
      expect(handler.csv_handler.description).to eq("<content provided>")

      handler.with_file do |fyle, ref_name|
        expect(ref_name).to eq("file contents")
        expect(fyle.class).to eq(Tempfile)
      end
    end

    it "should give me a file handler for path name" do
      path_name = Pathname.new("spec/cure/test_files/test_csv_file.csv")

      handler = Cure::Configuration::CsvFileProxy.load_file(:pathname, path_name, "path name")
      expect(handler.csv_handler.class).to eq(Cure::Configuration::PathnameHandler)
      expect(handler.csv_handler.type).to eq(:pathname)
      expect(handler.csv_handler.description).to eq("spec/cure/test_files/test_csv_file.csv")

      handler.with_file do |fyle, ref_name|
        expect(ref_name).to eq("path name")
        expect(fyle.class).to eq(Pathname)
      end
    end

    it "should fail with invalid type" do
      expect {
        Cure::Configuration::CsvFileProxy.load_file(:invalid, nil, "invalid")
      }.to raise_error(
        RuntimeError,
        "Invalid file type handler [invalid]. Supported: [:file, :file_contents, :path, :pathname]"
      )
    end

    it "should fail if called on base class" do
      default_handler = Cure::Configuration::DefaultFileHandler.new(:default, "none")
      expect {
        default_handler.with_file {}
      }.to raise_error(
        NotImplementedError,
        "Cure::Configuration::DefaultFileHandler has not implemented method 'with_file'"
      )

      expect {
        default_handler.description
      }.to raise_error(
        NotImplementedError,
        "Cure::Configuration::DefaultFileHandler has not implemented method 'description'"
      )
    end
  end
end