require "lzw/version"

require "lzw/bitbuf"
require "lzw/constants"
require "lzw/compressor"
require "lzw/decompressor"

# Scaling LZW, like Unix compress(1)
#
# The LZW gem offers:
# [{LZW}]               Simple functional interface
# [{LZW::Compressor}]   LZW compressor with more fine-grained controls
# [{LZW::Decompressor}] LZW decompressor in the same vein
# [{LZW::BitBuf}]       A String-backed buffer allowing bit-level operations
#
# {include:file:README.md}
#
# @see https://github.com/mariduv/rb-compress-lzw
# @see https://en.wikipedia.org/wiki/Lempel–Ziv–Welch
module LZW
  extend self

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

  # Exception class raised when compressed input is corrupt
  InputStreamError = Class.new(RuntimeError)
end
