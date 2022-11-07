// add_category.cdc
// Add a new category to contract Category

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_Mainnet       from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    let admin   : &DAAMDAAM_Mainnet_Mainnet.Admin

    prepare(admin: AuthAccount) {
        self.category = category
        self.admin    = admin.borrow<&DAAMDAAM_Mainnet_Mainnet.Admin>(from: DAAM_Mainnet.adminStoragePath)!
    }

    pre { !Categories.getCategories().contains(category) }

    execute {
        self.admin.addCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" added."))
    }
}
