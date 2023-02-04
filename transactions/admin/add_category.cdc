// add_category.cdc
// Add a new category to contract Category

import Categories from 0x7db4d10c78bad30a
import DAAM       from 0x7db4d10c78bad30a

transaction(category: String) {
    let category: String
    let admin   : &DAAM.Admin

    prepare(admin: AuthAccount) {
        self.category = category
        self.admin    = admin.borrow<&DAAM.Admin>(from: DAAM.adminStoragePath)!
    }

    pre { !Categories.getCategories().contains(category) }

    execute {
        self.admin.addCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" added."))
    }
}
