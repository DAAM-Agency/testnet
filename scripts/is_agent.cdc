// is_agent.cdc

import DAAM_V11 from 0xfd43f9148d4b725d

pub fun main(agent: Address): Bool? {
    return DAAM_V11.isAgent(agent)
}
// nil = not an agent, false = invited to be an agent, true = is an agent