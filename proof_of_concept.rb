# Original credit:
# https://gist.github.com/iainiain32/1823656
# Thanks a lot!
require 'rubygems'
require 'socket'

module Kopilot
  class XPlaneUDPConnection

    XP_PACKET_HEADER = 'CCCCC'
    XP_PACKET_DATA   = 'lffffffff'

    attr_reader :data_fields

    def initialize(port: 49003, data_fields: 2)
      @socket = UDPSocket.new
      @socket.bind('', port)
      @data_fields = data_fields
    end

    def received_data
      @socket.recv(XP_PACKET_HEADER.length + 36 * data_fields)
    end

    def read
      data_with_header = received_data.unpack(XP_PACKET_HEADER + XP_PACKET_DATA * data_fields)
      data = data_with_header[ XP_PACKET_HEADER.length .. (XP_PACKET_HEADER.length + data_fields*XP_PACKET_DATA.length) ]

      packet_hash = {}
      data.each_slice(XP_PACKET_DATA.length).to_a.each do |packet|
        packet_hash[packet[0]] = packet[1 .. XP_PACKET_DATA.length - 1]
      end

      return packet_hash
    end
  end
end

# Example use.
# Note that I configured X-Plane to spread out
# data on port 49003 via UDP.
conn = Kopilot::XPlaneUDPConnection.new

loop do
  update = conn.read
  key    = update.keys.compact.first

  latitude, longitude = update[key][0], update[key][1]

  puts "Captain, I've seen you at #{latitude}, #{longitude}!"
end
