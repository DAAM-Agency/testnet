// add_category.cdc
// Add a new category to contract Category

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_V18       from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    let admin   : &DAAM_V18.Admin

    prepare(admin: AuthAccount) {
        self.category = category
        self.admin    = admin.borrow<&DAAM_V18.Admin>(from: DAAM_V18.adminStoragePath)!
    }

    pre { !Categories.getCategories().contains(category) }

    execute {
        self.admin.addCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" added."))
    }
}
