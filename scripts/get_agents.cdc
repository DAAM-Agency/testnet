// get_creators.cdc
// Get List of Agents

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(): {Address: [DAAM_Mainnet.CreatorInfo] } {
    return DAAM_Mainnet.getAgents()
}