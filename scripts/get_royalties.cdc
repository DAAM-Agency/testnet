// get_royalties.cdc
// Get MID Royalties (MetadataViews.Royalties)

import MetadataViews from 0x631e88ae7f1d7c20
import DAAM          from 0xfd43f9148d4b725d

pub fun main(mid: UInt64): MetadataViews.Royalties
{
    return DAAM.getRoyalties(mid: mid)
}