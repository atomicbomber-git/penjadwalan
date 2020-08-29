context('Edit Kegiatan Belajar', () => {
    beforeEach(() => {
        cy.artisan(`db:reset-seed`)
        cy.login({ name: `Administrator`, username: 'administrator' })
        cy.visit(`kegiatan-belajar`)
    })

    it("Can edit kegiatan belajar", () => {
        cy.screenshot()

        cy.get(`.cypress-edit-button`)
            .first()
            .click()

        cy.get(`.cypress-submit-button`)
            .click()

        cy.get(`body`)
            .should(`contain`, `Data berhasil diperbarui.`)

        cy.screenshot()
    })
})
