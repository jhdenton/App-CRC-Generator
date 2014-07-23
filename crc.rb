# CRC calculators
# Adapted in part from "CRC Primer by Ross Williams." <http://www.riccibitti.com/crcguide.htm>


class CRC_Model
  def self.create (width = 16, poly = 0x8408, seed = 0x0000, rev_in = true, rev_out = true, xor_out = 0x0000, big_end = true)
    { :width => width, :poly => poly, :seed => seed, :rev_in => rev_in, :rev_out => rev_out, :xor_out => xor_out, :big_end => big_end } 
  end
end


class CRC_Calculator
  def initialize(model)
    @model = model
    @crc = 0x0
  end

  def start_block()
    @crc = @model[:seed]
  end

  def calc_data(data)
    msb = 1 << (@model[:width] - 1)
    mask = (((1 << (@model[:width] - 1)) - 1) << 1) | 1
    data = reverse(data, 8) if @model[:rev_in]
    @crc ^= data << (@model[:width] - 8)
    (0...8).each do |i|
      if (@crc & msb) != 0
        @crc = (@crc << 1) ^ @model[:poly] 
      else
        @crc = @crc << 1
      end
      @crc &= mask
    end
  end

  def get()
    retval = @crc
    retval = reverse(@crc, @model[:width]) if @model[:rev_out]
    retval = retval ^ @model[:xor_out]
    if @model[:big_end]
      temp = 0x00000000;
      puts "0x#{retval.to_s(16)}"
      (0...(@model[:width]/8)).each do |i|
        temp <<= 8;
        temp += retval & 0xFF
        retval >>= 8
        puts "0x#{temp.to_s(16)}"
      end
      retval = temp;
    end
    return retval
  end

  def array(block)
    self.start_block
    block.each do |dat|
      self.calc_data(dat)
    end
    return self.get
  end


  def self.calc_ccitt16xmodem(data, seed = 0x0000)
    crc = seed
    #puts "Calculating CRC..."
    data.each do |byte|
      mask = ((crc >> 8) ^ byte) & 0xFF
      mask = mask ^ (mask >> 4)
      table = mask ^ (mask << 5) ^ (mask << 12)
      crc = ((crc << 8) ^ table) & 0xFFFF
    end
    #puts "...CRC Done."
    return crc
  end

  private

    def reverse (data, bits)
      retval = 0
      (0...bits).each do |i|
        retval |= 1 << (bits - 1 - i) if (data & 1) != 0
        data >>= 1
      end
      return retval
    end

end
