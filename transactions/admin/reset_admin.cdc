// reset_creator.cdc

import DAAM_V3 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    prepare(signer: AuthAccount){
        DAAM.resetAdmin(newAdmin)
    }
}