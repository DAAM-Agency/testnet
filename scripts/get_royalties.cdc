// get_royalties.cdc
// Get MID Royalties (MetadataViews.Royalties)

import MetadataViews from 0x1d7e57aa55817448
import DAAM          from 0x7db4d10c78bad30a

pub fun main(mid: UInt64): MetadataViews.Royalties
{
    return DAAM.getRoyalties(mid: mid)
}