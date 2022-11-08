// is_nft_new.cdc

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(tokenID: UInt64): Bool {
    return DAAM_Mainnet.isNFTNew(id: tokenID)
}