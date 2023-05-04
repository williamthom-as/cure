# frozen_string_literal: true

RSpec.describe Cure do
  it "has a version number" do
    expect(Cure::VERSION).not_to be nil
  end

  it "inits from file" do
    expect {
      Cure.init_from_file("spec/cure/test_files/grouped_rows.rb")
          .with_csv_file(:pathname, Pathname.new("spec/cure/test_files/grouped_rows.csv"))
          .setup
          .run_export
    }.to_not raise_error
  end
end
