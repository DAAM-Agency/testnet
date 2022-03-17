// Get_metadatas_ref.cdc
// gets the Metadatas of a Creator

import DAAM from 0xfd43f9148d4b725d
transaction(creator: Address) {
    let creator : Address
    let admin   : &DAAM.Admin 

    prepare(admin: AuthAccount) {
        self.creator = creator  
        self.admin = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    pre { DAAM.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        let metadatas = self.admin.getMetadatasRef(creator: self.creator)
        log(metadatas)  
    }
}
