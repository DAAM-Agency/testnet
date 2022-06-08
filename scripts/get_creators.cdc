// get_creators.cdc
// Get List of Creators and their Agent

import DAAM from 0xfd43f9148d4b725d

pub fun main(): {Address: DAAM.CreatorInfo} { return DAAM.getCreators() }