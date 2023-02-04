// is_agent.cdc

import DAAM from 0x7db4d10c78bad30a

pub fun main(agent: Address): Bool? {
    return DAAM.isAgent(agent)
}
// nil = not an agent, false = invited to be an agent, true = is an agent