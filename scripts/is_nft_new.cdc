// is_nft_new.cdc

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(tokenID: UInt64): Bool {
    return DAAM_V14.isNFTNew(id: tokenID)
}