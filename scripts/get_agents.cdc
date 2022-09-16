// get_creators.cdc
// Get List of Creators and their Agent

import DAAM from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM.CreatorInfo] } {
    return DAAM.getAgents()
}