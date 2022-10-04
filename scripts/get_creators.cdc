// get_creators.cdc
// Get List of Creators

import DAAM_V23 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: DAAM_V23.CreatorInfo} { return DAAM_V23.getCreators() }