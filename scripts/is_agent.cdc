// is_agent.cdc

import DAAM_V15 from 0xa4ad5ea5c0bd2fba

pub fun main(agent: Address): Bool? {
    return DAAM_V15.isAgent(agent)
}
// nil = not an agent, false = invited to be an agent, true = is an agent