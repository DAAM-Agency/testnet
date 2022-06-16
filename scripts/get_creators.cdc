// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: DAAM_V14.CreatorInfo} { return DAAM_V14.getCreators() }