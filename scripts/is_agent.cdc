// is_agent.cdc

import DAAM from 0xfd43f9148d4b725d

pub fun main(agent: Address): Bool? {
    return DAAM.isAgent(agent)
}
// nil = not an agent, false = invited to be an agent, true = is an agent