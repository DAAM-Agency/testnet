// get_creators.cdc
// Get List of Creators and their Agent

import DAAM_Mainnet from 0xfd43f9148d4b725d

pub fun main(creator: Address): UFix64? {
    let list =  DAAM_Mainnet.getCreators()
    if list.containsKey(creator) {
        if list[creator]!.agent != nil {
            var agentCut = 0.0
            for cut in list[creator]!.agent.keys { agentCut = agentCut + list[creator]!.agent[cut]!.cut }
            return agentCut
        }
        list[creator]!.agent
    }
    return nil
}