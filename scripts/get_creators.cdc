// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_V17 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: DAAM_V17.CreatorInfo} { return DAAM_V17.getCreators() }