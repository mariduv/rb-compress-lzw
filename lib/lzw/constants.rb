module LZW::Constants
  MAGIC = "\037\235".b # byte 1-2: static magic
  MASK_BITS = 0x1f     # byte 3: mask for max_code_size
  MASK_BLOCK = 0x80    # byte 3: mask for block_mode

  RESET_CODE = 256   # block mode: reserved code: reset code table
  BL_INIT_CODE = 257 # block mode: first available code
  NR_INIT_CODE = 256 # normal mode: first available code

  INIT_CODE_SIZE = 9       # initial code size after header
  CHECKPOINT_BITS = 10_000 # block mode: check for falling compression
end
