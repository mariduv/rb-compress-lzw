require "lzw/version"

require "lzw/bitbuf"
require "lzw/constants"
require "lzw/compressor"
require "lzw/decompressor"

# Scaling LZW, like Unix compress(1)
#
# The LZW module offers:
# [{LZW::Simple}]       Straightforward compress/decompress calls in one place
# [{LZW::Compressor}]   LZW compressor with more fine-grained controls
# [{LZW::Decompressor}] LZW decompressor in the same vein
# [{LZW::BitBuf}]       An abstraction for modifying a String bitwise and
#                       with unsigned integers at arbitrary offsets and sizes.
#
# {include:file:README.md}
#
# @see https://github.com/mariduv/rb-compress-lzw
# @see https://en.wikipedia.org/wiki/Lempel–Ziv–Welch
module LZW
  # Simplest-use LZW compressor and decompressor
  class Simple
    # Compress input with defaults
    #
    # @param data [#each_byte] data to be compressed
    # @return [String] LZW compressed data
    def compress(data)
      LZW::Compressor.new.compress(data)
    end

    # Decompress input with defaults
    #
    # @param data [String] compressed data to be decompressed
    # @return [String] decompressed data
    # @raise [LZW::InputStreamError] if there is an error in the compressed stream
    def decompress(data)
      LZW::Decompressor.new.decompress(data)
    end
  end

  # Exception class raised when compressed input is corrupt
  InputStreamError = Class.new(RuntimeError)
end
