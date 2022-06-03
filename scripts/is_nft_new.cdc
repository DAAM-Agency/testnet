// is_nft_new.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(tokenID: UInt64): Bool {
    return DAAM_V11.isNFTNew(id: tokenID)
}