require "minitest/autorun"

require "lzw"

require_relative "testdata"

describe LZW::Simple do
  def simple = LZW::Simple.new

  it "can be created with no arguments" do
    _(simple).must_be_instance_of LZW::Simple
  end

  it "responds to compress and decompress" do
    %w[compress decompress].each { _(simple).must_respond_to it }
  end

  it "compresses simple data" do
    _(simple.compress(LOREM).bytesize).must_be :<, LOREM.bytesize
  end

  it "decompresses that simple data exactly" do
    _(simple.decompress(simple.compress(LOREM))).must_be :==, LOREM
  end

  it "raises errors for bad input" do
    _ { simple.decompress("foo") }.must_raise LZW::InputStreamError
  end

  it "decompresses big data exactly, bytewise" do
    _(simple.decompress(simple.compress(BIG))).must_equal BIG.b
  end
end
