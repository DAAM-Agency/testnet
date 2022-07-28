// get_royalties.cdc
// Get MID Royalties (MetadataViews.Royalties)

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM_V20          from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): MetadataViews.Royalties
{
    return DAAM_V20.getRoyalties(mid: mid)
}