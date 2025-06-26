require "minitest/autorun"

require "lzw"

require_relative "testdata"

describe LZW do
  it "extends itself" do
    %w[compress decompress].each { _(LZW).must_respond_to it }
  end

  it "compresses simple data" do
    _(LZW.compress(LOREM).bytesize).must_be :<, LOREM.bytesize
  end

  it "decompresses that simple data exactly" do
    _(LZW.decompress(LZW.compress(LOREM))).must_be :==, LOREM
  end

  it "raises errors for bad input" do
    _ { LZW.decompress("foo") }.must_raise LZW::InputStreamError
  end

  it "decompresses big data exactly, bytewise" do
    _(LZW.decompress(LZW.compress(BIG))).must_equal BIG.b
  end
end
