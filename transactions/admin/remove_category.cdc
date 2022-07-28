// remove_category.cdc
// Remove a new category to contract Category

import Categories from 0xa4ad5ea5c0bd2fba
import DAAM_V20       from 0xa4ad5ea5c0bd2fba

transaction(category: String) {
    let category: String
    let admin   : &DAAM_V20.Admin

    prepare(admin: AuthAccount) {
        self.category = category
        self.admin    = admin.borrow<&DAAM_V20.Admin>(from: DAAM_V20.adminStoragePath)!
    }

    pre { Categories.getCategories().contains(category) }

    execute {
        self.admin.removeCategory(name: self.category)
        log("Category: ".concat(self.category).concat(" removed."))
    }
}
