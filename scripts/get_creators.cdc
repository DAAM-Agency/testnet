// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: DAAM_Mainnet.CreatorInfo} { return DAAM_Mainnet.getCreators() }