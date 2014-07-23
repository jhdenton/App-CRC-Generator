require CRC

describe CRC do
  before all do
    m_test = [0x4D]
    now_test = "Now is the time for all good men".split("").map! { |c| c.to_d }
  end
  describe "CRC CCITT XMODEM of 'M' with default seed" do
    it "returns 0x9969" do
      CRC.calc_ccitt16xmodem(m_test).should eq 0x9969
    end
  end
end