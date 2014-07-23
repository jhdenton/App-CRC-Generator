require_relative '../crc'

require 'yaml'

describe CRC_Calculator do
  m_test = []
  now_test = []
  fox_test = []

  before :all do
    m_test = [0x4D]
    now_test = "Now is the time for all good men".split("").map!(&:ord)
    fox_test = "THE,QUICK,BROWN,FOX,0123456789".split("").map!(&:ord)
    @xmodem = CRC_Calculator.new(CRC_Model.create(16, 0x1021, 0x0000, false, false, 0x0000, false))
    @crc16 = CRC_Calculator.new(CRC_Model.create(16, 0x1021, 0xFFFF, false, false, 0x0000, false))
    @crc32 = CRC_Calculator.new(CRC_Model.create(32, 0x04C11DB7, 0xFFFFFFFF, true, true, 0xFFFFFFFF, false))
  end

  describe "CRC CCITT XMODEM of 'M'" do
    context "with default seed" do
      it "returns 0x9969" do
        expect(@xmodem.array(m_test)).to eq 0x9969
      end
    end
  end
  describe "CRC CCITT XMODEM of 'Now is the time for all good men'" do
    context "with default seed" do
      it "returns 0x736C" do
        expect(@xmodem.array(now_test)).to eq 0x736C
      end
    end
  end
  describe "CRC CCITT XMODEM of 'THE,QUICK,BROWN,FOX,0123456789'" do
    context "with default seed" do
      it "returns 0x0498" do
        expect(@xmodem.array(fox_test)).to eq 0x0498
      end
    end
  end

  describe "CRC-16 'M'" do
    context "with default seed" do
      it "returns 0x7899" do
        expect(@crc16.array(m_test)).to eq 0x7899
      end
    end
  end
  describe "CRC-16 of 'Now is the time for all good men'" do
    context "with default seed" do
      it "returns 0x8220" do
        expect(@crc16.array(now_test)).to eq 0x8220
      end
    end
  end

  describe "CRC-32 of 'M'" do
    context "with default seed" do
      it "returns 0xDA6FD2A0" do
        expect(@crc32.array(m_test)).to eq 0xDA6FD2A0
      end
    end
  end
  describe "CRC 32 of 'Now is the time for all good men'" do
    context "with default seed" do
      it "returns 0x7E457762" do
        expect(@crc32.array(now_test)).to eq 0x7E457762
      end
    end
  end
end