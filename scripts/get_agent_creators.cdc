// get_agent_creators.cdc
// Get List of Creators and their Agent

import DAAM_Mainnet from 0xa4ad5ea5c0bd2fba

pub fun main(agent: Address): [Address]? {
    return DAAM_Mainnet.getAgentCreators(agent: agent)
}
