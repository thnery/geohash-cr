require "./spec_helper"

describe GeohashCr::Proximity do
  it "ensure in circle" do
    GeohashCr::Proximity.in_circle_check(12, 77, 12.1, 77, 100).should eq(true)
  end

  it "ensure not in circle" do
    GeohashCr::Proximity.in_circle_check(12, 75, 33.1, 77, 10).should eq(false)
  end

  it "get centroid" do
    GeohashCr::Proximity.get_centroid(10, 10, 10, 10).should eq([15, 15])
  end

  it "converts to location" do
    GeohashCr::Proximity.convert_to_latlon(1000.0, 1000.0, 12.0, 77.0).should eq([12.008993216059187, 77.0091941298557])
  end

  it "creates geohash" do
    # expectation = "tdnu20t9,tdnu20t8,tdnu20t3,tdnu20t2,tdnu20mz,tdnu20mx,tdnu20tc,tdnu20tb,tdnu20td,tdnu20tf".split(',').sort
    # GeohashCr::Proximity.create_geohash(12.0, 77.0, 20.0, 8).split(',').sort.should eq(expectation)
  end

  it "gets combinations" do
    string = "tdnu2"
    combinations = ["tdnu20", "tdnu21", "tdnu22", "tdnu23", "tdnu24", "tdnu25", "tdnu26", "tdnu27", "tdnu28", "tdnu29",
                    "tdnu2b", "tdnu2c", "tdnu2d", "tdnu2e", "tdnu2f", "tdnu2g", "tdnu2h", "tdnu2j", "tdnu2k", "tdnu2m",
                    "tdnu2n", "tdnu2p", "tdnu2q", "tdnu2r", "tdnu2s", "tdnu2t", "tdnu2u", "tdnu2v", "tdnu2w", "tdnu2x",
                    "tdnu2y", "tdnu2z"]

    output = GeohashCr::Proximity.get_combinations(string)
    output.should eq(combinations)
  end

  it "compress" do
    geohashes = ["tdnu20", "tdnu21", "tdnu22", "tdnu23", "tdnu24", "tdnu25", "tdnu26", "tdnu27", "tdnu28", "tdnu29",
                 "tdnu2b", "tdnu2c", "tdnu2d", "tdnu2e", "tdnu2f", "tdnu2g", "tdnu2h", "tdnu2j", "tdnu2k", "tdnu2m",
                 "tdnu2n", "tdnu2p", "tdnu2q", "tdnu2r", "tdnu2s", "tdnu2t", "tdnu2u", "tdnu2v", "tdnu2w", "tdnu2x",
                 "tdnu2y", "tdnu2z"]

    final_geohash = ["tdnu2"]

    output = GeohashCr::Proximity.compress(geohashes)
    final_geohash.should eq(output)
  end
end
