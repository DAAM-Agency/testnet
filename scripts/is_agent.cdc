// is_agent.cdc

<<<<<<< HEAD
import DAAM_V5from 0xa4ad5ea5c0bd2fba
=======
import DAAM_V5 from 0xa4ad5ea5c0bd2fba
>>>>>>> merge_dev

pub fun main(agent: Address): Bool? {
    return DAAM_V5.isAgent(agent)
}
// nil = not an agent, false = invited to be an agent, true = is an agent