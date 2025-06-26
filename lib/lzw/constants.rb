module LZW::Constants
  MAGIC = "\037\235".b      # static magic bytes
  MASK_BITS = 0x1f              # mask for 3rd byte for max_code_size
  MASK_BLOCK = 0x80              # mask for 3rd byte for block_mode
  RESET_CODE = 256               # block mode code to reset code table
  BL_INIT_CODE = 257               # block mode first available code
  NR_INIT_CODE = 256               # normal mode first available code
  INIT_CODE_SIZE = 9                 # initial code size beyond the header
  CHECKPOINT_BITS = 10_000            # block mode check for falling compression

  private_constant :MAGIC, :MASK_BITS, :MASK_BLOCK
  private_constant :RESET_CODE, :BL_INIT_CODE, :NR_INIT_CODE
  private_constant :INIT_CODE_SIZE, :CHECKPOINT_BITS
end
