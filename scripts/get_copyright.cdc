// get_copyright.cdc

<<<<<<< HEAD
import DAAM_V10 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V10.CopyrightStatus? {
    return DAAM_V10.getCopyright(mid: mid)
=======
import DAAM_V14 from 0xa4ad5ea5c0bd2fba

pub fun main(mid: UInt64): DAAM_V14.CopyrightStatus? {
    return DAAM_V14.getCopyright(mid: mid)
>>>>>>> DAAM_V14
}
// nil = non-existent MID