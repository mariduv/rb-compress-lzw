# compress-lzw

[API Documentation](https://mariduv.github.io/rb-compress-lzw/)

[![CircleCI](https://circleci.com/gh/mariduv/rb-compress-lzw.svg?style=svg)](https://circleci.com/gh/mariduv/rb-compress-lzw)

## About

This gem is a Ruby implementation of the Lempel-Ziv-Welch compression
algorithm created in 1984.  As of 2004, all patents on it had expired.

This implementation is compatible with the classic unix compress tool, and
*not* compatible with the LZW compression used within GIF streams.

LZW is notable in two ways:  it is dictionary-based compression but does not
need to pass that dictionary within its files, instead decompression relies
on progressively building a dictionary in the same way as the compressor. It
also works outside the boundaries of bytes, writing its dictionary codes 9
bits at a time and scaling up as the codes increase to 16 bits.

To get right to work, check out the [LZW][] module.

[LZW]: https://mariduv.github.io/rb-compress-lzw/LZW.html

## TODO

* Convert from circleci to github actions

* Code isn't the most efficient, but get impl right first. Buffering with a
queue of 8 codes makes the packed code always fit an octet boundary.

* Add a set of tests that tries to find compress binaries installed to use
for compatibility tests.

