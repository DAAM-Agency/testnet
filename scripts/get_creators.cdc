// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(): {Address: DAAM_Mainnet.CreatorInfo} { return DAAM_Mainnet.getCreators() }