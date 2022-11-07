// get_agent_creators.cdc
// Get List of Creators and their Agent

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(agent: Address): [Address]? {
    return DAAM_Mainnet.getAgentCreators(agent: agent)
}
