# Scaling LZW decompressor
class LZW::Decompressor
  include LZW::Constants

  # Given a String(ish) of LZW-compressed data, return the decompressed data
  # as a String left in "ASCII-8BIT" encoding.
  #
  # @param data [String] Compressed input data
  # @return [String]
  # @raise [LZW::InputStreamError] if there is an error in the compressed stream
  def decompress(data)
    reset

    @data = LZW::BitBuf.new(field: data)
    @data_pos = 0

    read_magic(@data)
    @data_pos = 24

    # we've read @block_mode from the header now, so make sure our init_code
    # is set properly
    str_reset

    next_increase = 2**@code_size

    seen = read_code
    @buf << @str_table[seen]

    while (code = read_code)

      if @block_mode && code == RESET_CODE
        str_reset

        seen = read_code
        # warn "reset at #{data_pos} initial code #{@str_table[seen]}"
        next
      end

      if (word = @str_table.fetch(code, nil))
        @buf << word

        @str_table[@next_code] = @str_table[seen] + word[0, 1]

      elsif code == @next_code
        word = @str_table[seen]
        @str_table[code] = word + word[0, 1]

        @buf << @str_table[code]

      else
        raise LZW::InputStreamError, "(#{code} != #{@next_code}) input may be corrupt at bit #{data_pos - @code_size}"
      end

      seen = code
      @next_code += 1

      if @next_code >= next_increase
        if @code_size < @max_code_size
          @code_size += 1
          next_increase *= 2
          # warn "decode up to #{@code_size} for next #{@next_code} max #{@max_code_size} at #{data_pos}"
        end
      end

    end

    @buf
  end

  # Reset the state of the decompressor. This is run at the beginning of
  # {#decompress}, so it's not necessary for reuse of an instance, but this
  # allows wiping the string code table and buffer from the object instance.
  def reset
    @buf = "".b
    @str_table = []
  end

  private

  # Build up the initial string table, reset code size and next code.
  def str_reset
    @str_table = []
    (0..255).each do |i|
      @str_table[i] = i.chr
    end

    @code_size = INIT_CODE_SIZE
    @next_code = @block_mode ? BL_INIT_CODE : NR_INIT_CODE
  end

  # Verify the two magic bytes at the beginning of the stream and read bit
  # and block data from the third.
  def read_magic(data)
    magic = +""
    (0..2).each do |byte|
      magic << data.get_varint(byte * 8, 8).chr
    end

    if magic.bytesize != 3 || magic[0, 2] != MAGIC
      raise LZW::InputStreamError, "Invalid compress(1) header " \
        "(expected #{MAGIC.unpack("h*")}, got #{magic[0, 2].unpack("h*")})"
    end

    bits = magic.getbyte(2)
    @max_code_size = bits & MASK_BITS
    @block_mode = ((bits & MASK_BLOCK) >> 7) == 1
  end

  def read_code
    code = @data.get_varint(@data_pos, @code_size)
    @data_pos += @code_size
    code
  end
end
