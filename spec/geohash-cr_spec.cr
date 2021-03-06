require "./spec_helper"

describe GeohashCr do
  it "decodes" do
    {
      "c216ne" => [[45.3680419921875, -121.70654296875], [45.37353515625, -121.695556640625]],
      "C216Ne" => [[45.3680419921875, -121.70654296875], [45.37353515625, -121.695556640625]],
      "dqcw4"  => [[39.0234375, -76.552734375], [39.0673828125, -76.5087890625]],
      "DQCW4"  => [[39.0234375, -76.552734375], [39.0673828125, -76.5087890625]],
    }.each do |hash, latlng|
      GeohashCr.decode(hash).should eq(latlng)
    end
  end
end
