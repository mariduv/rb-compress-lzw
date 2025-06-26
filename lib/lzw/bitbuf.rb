# Wrap up a String, in binary encoding, for single-bit manipulation and
# working with variable-size integers.  This is necessary because our LZW
# streams don't align with byte boundaries beyond the 4th byte, they start
# writing codes 9 bits at a time (by default) and scale up from that later.
#
# Derived from Gene Hsu's work at
# https://github.com/genehsu/bitarray/blob/master/lib/bitarray/string.rb but
# it wasn't worth inheriting from an unaccepted pull to a gem that's
# unmaintained.  Mostly, masking out is way smarter than something like vec()
# which is what I'm doing in the Perl version of this right now.
#
# Compared to bitarray:
# I'm forcing this to default-0 for bits, making a fixed size unnecessary,
# and supporting both bit orders. And changing the interface, so I shouldn't
# subclass anyway.
class LZW::BitBuf
  include Enumerable

  AND_BITMASK = %w[
    01111111
    10111111
    11011111
    11101111
    11110111
    11111011
    11111101
    11111110
  ].map { |w| [w].pack("b8").getbyte(0) }.freeze

  OR_BITMASK = %w[
    10000000
    01000000
    00100000
    00010000
    00001000
    00000100
    00000010
    00000001
  ].map { |w| [w].pack("b8").getbyte(0) }.freeze
  private_constant :AND_BITMASK, :OR_BITMASK

  # If true, {#get_varint} and {#set_varint} work in MSB-first order.
  # @return [Boolean]
  attr_reader :msb_first

  # The string, set to binary encoding, wrapped by this BitBuf.  This is
  # essentially the "pack"ed form of the bitfield.
  # @return [String]
  attr_reader :field

  # @param field [String] Optional string to wrap with BitBuf. Will be
  #   copied with binary encoding.
  # @param msb_first [Boolean] Optionally force bit order used when
  #   writing integers to the bitfield. Default false.
  def initialize(
    field: "\000",
    msb_first: false
  )
    @field = field.b
    @msb_first = msb_first
  end

  # Set a specific bit at pos to val. Trying to set a bit beyond the
  # currently defined {#bytesize} will automatically grow the BitBuf to the
  # next whole byte needed to include that bit.
  #
  # @param pos [Numeric] 0-indexed bit position
  # @param val [Numeric] 0 or 1.  2 isn't yet allowed for bits.
  def []=(pos, val)
    byte, bit = byte_divmod(pos)

    # puts "p:#{pos} B:#{byte} b:#{bit} = #{val}  (#{self[pos]})"

    case val
    when 0
      @field.setbyte(
        byte,
        @field.getbyte(byte) & AND_BITMASK[bit]
      )
    when 1
      @field.setbyte(
        byte,
        @field.getbyte(byte) | OR_BITMASK[bit]
      )
    else
      fail ArgumentError, "Only 0 and 1 are valid for a bit field"
    end
  end

  # Read a bit at pos.  Trying to read a bit beyond the currently defined
  # {#bytesize} will automatically grow the BitBuf to the next whole byte
  # needed to include that bit.
  #
  # @param pos [Numeric] 0-indexed bit position
  # @return [Fixnum] the bit value at the requested bit position.
  def [](pos)
    byte, bit = byte_divmod(pos)

    (@field.getbyte(byte) >> bit) & 1
  end

  # Iterate over the BitBuf bitwise.
  def each
    (bytesize * 8).times do |pos|
      yield self[pos]
    end
  end

  # Returns the BitBuf as a text string of zeroes and ones.
  def to_s
    @field.unpack1("b*")
  end

  # Returns the current bytesize of the BitBuf
  # @return [Numeric]
  # @!parse attr_reader :bytesize
  def bytesize
    @field.bytesize
  end

  # Store an unsigned integer in of "bits" length, at "pos" position, and in
  # LSB-first order unless {#msb_first} is true. This method will grow the
  # BitBuf as necessary, in whole bytes.
  #
  # @param pos [Numeric] 0-indexed bit position to write the first bit
  # @param width [Numeric] Default 8. The desired size of the supplied
  #   integer. There is no overflow check.
  # @param val [Numeric] The integer value to be stored in the BitBuf.
  def set_varint(pos, width, val)
    fail ArgumentError, "integer overflow for #{width} bits: #{val}" \
      if val > 2**width

    width.times do |bit_offset|
      self[pos + (@msb_first ? (width - bit_offset - 1) : bit_offset)] =
        (val >> bit_offset) & 1
    end
    self
  end

  # Fetch an unsigned integer of "width" size from "pos" in the BitBuf.
  # Unlike other methods, if "pos" is beyond the end of the BitBuf, {nil} is
  # returned.
  #
  # @return [Numeric, nil]
  def get_varint(pos, width)
    return nil if (pos + width) > bytesize * 8

    int = 0
    width.times do |bit_offset|
      int += 2**bit_offset *
        self[pos + (@msb_first ? (width - bit_offset) : bit_offset)]
    end

    int
  end

  private

  # Wraps divmod to always divide by 8 and automatically grow the BitBuf as
  # soon as we start poking beyond the end. Side-effecty.
  #
  # @param [Numeric] pos A 0-indexed bit position.
  # @return [Array<Numeric>] byte index, bit offset
  def byte_divmod(pos)
    byte, bit = pos.divmod(8)

    if byte > (bytesize - 1)
      @field << "\000" * (byte - @field.bytesize + 1)
    end

    [byte, bit]
  end
end


