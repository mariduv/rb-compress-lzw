require "minitest/autorun"

require "lzw"

require_relative "testdata"

describe LZW::Compressor do
  def c = LZW::Compressor.new

  it "can be created with no arguments" do
    _(c).must_be_instance_of LZW::Compressor
  end

  it "can be created with all arguments" do
    _(LZW::Compressor.new(
      block_mode: 0,
      max_code_size: 14
    )).must_be_instance_of LZW::Compressor
  end

  it "rejects invalid arguments" do
    _ {
      LZW::Compressor.new(max_code_size: 35)
    }.must_raise ArgumentError

    _ {
      LZW::Compressor.new(max_code_size: 8)
    }.must_raise ArgumentError
  end

  it "responds to compress and reset" do
    %w[compress reset].each { |m| _(c).must_respond_to m }
  end

  it "has accessors block_mode and max_code_size" do
    %w[
      block_mode max_code_size
    ].each { |m| _(c).must_respond_to m }
  end

  it "compresses simple data" do
    _(c.compress(LOREM).bytesize).must_be :<, LOREM.bytesize
  end

  it "compresses big data" do
    _(c.compress(BIG).bytesize).must_be :<, BIG.bytesize
  end

  it "compresses at a limited code size" do
    _(LZW::Compressor.new(
      max_code_size: 9
    ).compress(LOREM)).must_be_instance_of String
  end
end
