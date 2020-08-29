context('Login', () => {
    beforeEach(() => {
        cy.artisan(`db:reset-seed`)
        cy.visit('/login')
    })

    it("Fails whens submitted with incorrect data", () => {
        cy.screenshot()

        cy.get("form#login-form input[name=username]")
            .type("whatever")

        cy.get("form#login-form input[name=password]")
            .type("whatever")

        cy.get("form#login-form button:not([type=button])")
            .click()

        cy.location("pathname").should("eq", "/login")

        cy.get("form#login-form input[name=username]")
            .should("have.class", "is-invalid")

        cy.screenshot()
    })


    it("Success when submitted with correct data.", () => {
        cy.screenshot()

        cy.get("form#login-form input[name=username]")
            .type("admin")

        cy.get("form#login-form input[name=password]")
            .type("admin")

        cy.get("form#login-form button:not([type=button])")
            .click()

        cy.location("pathname").should("eq", "/kegiatan-belajar")

        cy.screenshot()
    })
})
