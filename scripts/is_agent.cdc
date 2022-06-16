// is_agent.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(agent: Address): Bool? {
    return DAAM_V10.isAgent(agent)
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(agent: Address): Bool? {
    return DAAM_V14.isAgent(agent)
>>>>>>> DAAM_V14
}
// nil = not an agent, false = invited to be an agent, true = is an agent