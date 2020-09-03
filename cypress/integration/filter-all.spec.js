context('Select all filters', () => {
    beforeEach(() => {
        cy.artisan(`db:reset-seed`)
        cy.visit(`/`)
    })

    it("Can select all filter", () => {
        cy.document().then(doc => {
            let options = doc.querySelectorAll("#program_studi_id option")
            options.forEach(option => {
                cy.screenshot()

                cy.get("#program_studi_id")
                    .select(option.value)

                cy.get("form.filter-form")
                    .submit()

                cy.screenshot()
            })
        })
    })
})
