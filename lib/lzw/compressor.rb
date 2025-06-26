# Scaling LZW data compressor with some configurables
class LZW::Compressor
  include LZW::Constants

  # If true, enables compression in block mode. Default true.
  #
  # After reaching {#max_code_size} bits per code, the compression dictionary
  # and code size may be reset if a drop in compression ratio is observed.
  # @return [Boolean]
  attr_reader :block_mode

  # The maximum code size, in bits, that compression may scale up to.
  # Default 16.
  #
  # Valid values are init_code_size(9) to 31.  Values greater than 16 break
  # compatibility with compress(1).
  # @return [Fixnum]
  attr_reader :max_code_size

  # LZW::Compressors work fine with the default settings.
  #
  # @param block_mode [Boolean] (see {#block_mode})
  # @param max_code_size [Fixnum] (see {#max_code_size})
  def initialize(
    block_mode: true,
    max_code_size: 16
  )
    unless max_code_size.between?(INIT_CODE_SIZE, 31)
      fail ArgumentError, "max_code_size must be between #{INIT_CODE_SIZE} and 31"
    end

    @block_mode = block_mode
    @max_code_size = max_code_size
  end

  # Given a String(ish) of data, return the LZW-compressed result as another
  # String.
  #
  # @param data [#each_byte<#chr>] Input data
  # @return [String]
  def compress(data)
    reset

    # In block mode, we track compression ratio
    @checkpoint = nil
    @last_ratio = nil
    @bytes_in = 0

    seen = +""
    @next_increase = 2**@code_size

    data.each_byte do |byte|
      char = byte.chr
      @bytes_in += 1

      if @code_table.has_key?(seen + char)
        seen << char
      else
        write_code(@code_table[seen])

        new_code(seen + char)

        check_ratio_at_cap

        seen = char
      end
    end

    write_code(@code_table[seen])

    @buf.field
  end

  # Reset compressor state.  This is run at the beginning of {#compress}, so
  # it's not necessary for repeated compression, but this allows wiping the
  # last code table and buffer from the object instance.
  def reset
    @buf = LZW::BitBuf.new
    @buf_pos = 0

    # begin with the magic bytes
    magic.each_byte do |b|
      @buf.set_varint(@buf_pos, 8, b.ord)
      @buf_pos += 8
    end

    code_reset
  end

  private

  # Re-initialize the code table, code size and next code.  This happens at
  # the beginning of compression and whenever RESET_CODE is added to the
  # stream (block mode).
  def code_reset
    @code_table = {}
    (0..255).each do |i|
      @code_table[i.chr] = i
    end

    @at_max_code = 0
    @code_size = INIT_CODE_SIZE
    @next_code = @block_mode ? BL_INIT_CODE : NR_INIT_CODE
    @next_increase = 2**@code_size
  end

  # Prepare the header magic bytes for this stream.
  # @return [String]
  def magic
    MAGIC + (
      (@max_code_size & MASK_BITS) |
      (@block_mode ? MASK_BLOCK : 0)
    ).chr
  end

  # Store a new code in our table and bump code sizes if necessary.
  def new_code(word)
    if @next_code >= @next_increase
      if @code_size < @max_code_size
        @code_size += 1
        @next_increase *= 2

        # warn "encode up to #{@code_size} for next_code #{@next_code} at #{@buf_pos}"
      else
        @at_max_code = 1
      end
    end

    if @at_max_code.zero?
      @code_table[word] = @next_code
      @next_code += 1
    end
  end

  # Write a code at the current code size and bump the position pointer.
  def write_code(code)
    @buf.set_varint(@buf_pos, @code_size, code)
    @buf_pos += @code_size
  end

  # Once we've reached the max_code_size, if in block mode, issue a code
  # reset if the compression ratio falls.
  def check_ratio_at_cap
    return if !@block_mode
    return if !@at_max_code

    if @checkpoint.nil?
      @checkpoint = @buf_pos + CHECKPOINT_BITS
    elsif @buf_pos > @checkpoint
      @ratio = @bytes_in / (@buf_pos / 8)
      @last_ratio = @ratio if @last_ratio.nil?

      if @ratio >= @last_ratio
        @last_ratio = @ratio
        @checkpoint = @buf_pos + CHECKPOINT_BITS
      elsif @ratio < @last_ratio
        # warn "writing reset at #{@buf_pos} #{@buf_pos.divmod(8).join(',')}"
        write_code(RESET_CODE)

        code_reset

        @checkpoint, @last_ratio = [nil, nil]
      end
    end
  end
end


