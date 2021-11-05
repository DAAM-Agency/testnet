// reset_creator.cdc

import DAAM_V4 from 0xa4ad5ea5c0bd2fba

transaction(newAdmin: Address)
{
    prepare(signer: AuthAccount){
        DAAM_V4.resetAdmin(newAdmin)
    }
}