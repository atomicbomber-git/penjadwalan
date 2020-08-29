context('Create Kegiatan Belajar', () => {
    beforeEach(() => {
        cy.artisan(`db:reset-seed`)
        cy.login({ name: `Administrator`, username: 'administrator' })

        cy.visit(`kegiatan-belajar/create?tipe_semester_id=2&tahun_ajaran_id=1&program_studi_id=12`)
    })

    it("Can create kegiatan belajar", () => {
        cy.screenshot()

        cy.get("#mata_kuliah_id_container div.multiselect")
            .focus()
            .click()
            .type(`{downarrow}{enter}`)

        for (let i = 0; i < 5; ++i) {
            cy.get(`button.cypress-add-tipe-kelas`)
                .click()

            cy.get(`input#tipe_${i}`)
                .type(`${i}`)
        }

        cy.get(`select#hari_dalam_minggu`)
            .select(`1`)

        cy.get(`input#tanggal_mulai`).type(`2020-01-01`)
        cy.get(`input#tanggal_selesai`).type(`2020-06-30`)
        cy.get(`input#waktu_mulai`).type(`13:00`)
        cy.get(`input#waktu_selesai`).type(`17:00`)

        cy.get(".cypress-ruangan-id-container div.multiselect")
            .focus()
            .click()
            .type(`{downarrow}{downarrow}{enter}`)

        cy.get(`button.cypress-kegiatan-belajar-create-submit`)
            .click()

        cy.url()
            .should(`include`, `kegiatan-belajar?tipe_semester_id=2&tahun_ajaran_id=1&program_studi_id=12`)

        cy.screenshot()
    })
})
