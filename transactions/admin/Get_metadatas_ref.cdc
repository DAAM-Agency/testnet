// Get_metadatas_ref.cdc
// gets the Metadatas of a Creator

import DAAM from 0xfd43f9148d4b725d
transaction(creator: Address) {
    let creator : Address
    let signer  : AuthAccount

    prepare(signer: AuthAccount) {
        self.creator = creator  
        self.signer = signer
    }

    pre { DAAM.isCreator(creator) != nil : creator.toString().concat(" is not a Creator.") }

    execute {
        let metadatas = self.signer.getMetadatasRef(access: self.creator)
        log(metadatas)  
    }
}
