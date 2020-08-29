context('Destroy Kegiatan Belajar', () => {
    beforeEach(() => {
        cy.artisan(`db:reset-seed`)
        cy.login({ name: `Administrator`, username: 'administrator' })
        cy.visit(`kegiatan-belajar`)
    })

    it("Can destroy kegiatan belajar", () => {
        cy.screenshot()

        cy.get(`.cypress-delete-button`)
            .first()
            .submit()

        cy.get(`body`)
            .should(`contain`, `Data berhasil dihapus.`)

        cy.screenshot()
    })
})
