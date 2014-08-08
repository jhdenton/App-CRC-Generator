#!/usr/bin/env ruby
require_relative '../crc'

class IntelHex
  def self.parse_into_memory(file_handle, memory_start, memory_end, fill)
    retval = Array.new(memory_end - memory_start + 1, fill)
    if file_handle.class == File
      #puts "Parsing hex file..."
      segment_addr = 0x000000
      extended_addr = 0x00000000
      file_handle.each do |line|
        /^:(?<count_str>\w\w)(?<addr_str>\w\w\w\w)(?<type_str>\w\w)(?<data_str>\w*)(?<check_str>\w\w)$/ =~ line.upcase
        count = count_str.hex
        puts "--Bad line count." if count != data_str.length / 2
        checksum = check_str.hex
        case type_str
        when "00" # Data
          start = extended_addr + addr_str.hex
          index = 0
            (start...(start+count)).each do |addr|
              data = data_str[index..(index + 1)].hex
              if addr > (memory_start - 1) && addr < (memory_end + 1)
                retval[addr - memory_start] = data
              end
              index += 2
            end
        when "01" # EOF
          #puts "...Done parsing."
        when "02" # Extended Segment Address
          puts "--Bad data size." if 4 != data_str.length
          segment_addr = data_str.hex * 16
        when "03" # Start Segment Address
          puts "--Bad data size." if 8 != data_str.length
          puts "  80x86 CS = #{data_str[0..1].hex} and IP = #{data_str[2..3].hex}."
        when "04" # Extended Linear Address
          puts "--Bad data size." if 4 != data_str.length
          extended_addr = data_str.hex * 65536
          #puts "  extended: #{extended_addr.to_s(16)}"
        when "05" # Start Linear Address
          puts "--Bad data size." if 8 != data_str.length
          puts "  80x86 EIP = #{data_str.hex}."
        else
          puts "--Bad line type."
        end
      end
    end
    return retval
  end
end

def calc_crc32(data)
  crc32 = CRC_Calculator.new(CRC_Model.create(32, 0x04C11DB7, 0xFFFFFFFF, true, true, 0xFFFFFFFF, false))
  return crc32.array(data)
end


def main
  infilename = ARGV[0]
  crc_location = 0x14F00
  if infilename == "?" || infilename == "-help" || infilename == "" || infilename.nil?
    puts "Call as follows: crc_gen.rb <hex file name>"
  else
    handle = File.open(infilename)
    if !handle.nil?
      binary = IntelHex.parse_into_memory(handle, 0x00400, 0x2A1FF, 0xFF)
      #p binary

      effective_addr = 0x00200
      sub = 0
      app_memory = []
      app_crc = []
      pdi_memory = []
      pdi_crc = []
      binary.each do |byte|
        if effective_addr < 0x15000
          case sub
          when 0,1,2
            if effective_addr < crc_location
              app_memory << byte
            else
              app_crc << byte
            end
          else
            effective_addr += 2
          end
        else
          case sub
          when 0,1
            if effective_addr < 0x150F8
              pdi_memory << byte
            else
              pdi_crc << byte
            end
          when 2
          else
            effective_addr += 2
          end
        end
        sub = (sub + 1) % 4
      end
      #p memory

      crc_calced = calc_crc32(app_memory).to_s(16).upcase
      crc_stored = ((app_crc[4] << 24) + (app_crc[3] << 16) + (app_crc[1] << 8) + app_crc[0]).to_s(16) .upcase
      if crc_calced != crc_stored
        puts "App CRC: 0x" + crc_stored + "  Should be: 0x"+ crc_calced
      else
        puts "App CRC Good: 0x" + crc_calced
      end

      crc_calced = calc_crc32(pdi_memory).to_s(16).upcase
      crc_stored = ((pdi_crc[5] << 24) + (pdi_crc[4] << 16) + (pdi_crc[1] << 8) + pdi_crc[0]).to_s(16).upcase
      if crc_calced != crc_stored
        puts "PDI CRC: 0x" + crc_stored + "  Should be: 0x"+ crc_calced
      else
        puts "PDI CRC Good: 0x" + crc_calced
      end

      handle.close
      #puts "Operation complete."
    else
      puts "File not opened."
    end
  end
end

main




