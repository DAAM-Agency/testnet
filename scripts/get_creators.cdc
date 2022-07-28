// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_V20 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: DAAM_V20.CreatorInfo} { return DAAM_V20.getCreators() }