describe "CanadianBankAccount", ->
  factory = (attributes = {}) ->
    new CanadianBankAccount({
      institution: attributes.institution ? "001"
      transit: attributes.transit ? "12345"
      account: attributes.account ? "1234567"
    })

  describe "#hasValidations", ->
    context "institution is known", ->
      it "returns true", ->
        expect(factory().hasValidations()).toBe(true)

    context "institution is unknown", ->
      it "returns false", ->
        expect(factory(institution: "789").hasValidations()).toBe(false)

  describe "#isAccountValid", ->
    context "with a Scotiabank account", ->
      it "returns true for valid account numbers", ->
        expect(factory(institution: "002", account: "1234567").isAccountValid()).toBe(true)
        expect(factory(institution: "002", account: "123456789123").isAccountValid()).toBe(true)

      it "returns false for invalid account numbers", ->
        expect(factory(institution: "002", account: "").isAccountValid()).toBe(false)
        expect(factory(institution: "002", account: "123").isAccountValid()).toBe(false)
        expect(factory(institution: "002", account: "12345678").isAccountValid()).toBe(false)

    context "with a BMO account", ->
      it "returns true for valid account number", ->
        expect(factory(institution: "001", account: "1234567").isAccountValid()).toBe(true)

      it "returns false for invalid account number", ->
        expect(factory(institution: "001", account: "").isAccountValid()).toBe(false)
        expect(factory(institution: "001", account: "123").isAccountValid()).toBe(false)
        expect(factory(institution: "001", account: "12345678").isAccountValid()).toBe(false)

    context "for an unknown institution", ->
      it "returns true", ->
        expect(factory(institution: "789").isAccountValid()).toBe(true)

  describe "#isTransitValid", ->
    context "with a BMO account", ->
      it "returns true for any 5-digit string", ->
        expect(factory(institution: "001", transit: "12345").isTransitValid()).toBe(true)

      it "return false for any non-5-digit string", ->
        expect(factory(institution: "001", transit: "").isTransitValid()).toBe(false)
        expect(factory(institution: "001", transit: "123").isTransitValid()).toBe(false)
        expect(factory(institution: "001", transit: "123456").isTransitValid()).toBe(false)

    context "with an HSBC account", ->
      it "returns true for any 5-digit string starting with 10", ->
        expect(factory(institution: "016", transit: "10345").isTransitValid()).toBe(true)

      it "returns false for any invalid transit number", ->
        expect(factory(institution: "016", transit: "").isTransitValid()).toBe(false)
        expect(factory(institution: "016", transit: "10").isTransitValid()).toBe(false)
        expect(factory(institution: "016", transit: "12345").isTransitValid()).toBe(false)
        expect(factory(institution: "016", transit: "103456").isTransitValid()).toBe(false)

    context "for an unknown institution", ->
      it "uses the default transit regex", ->
        expect(factory(institution: "789", transit: "123").isTransitValid()).toBe(false)
        expect(factory(institution: "789", transit: "12345").isTransitValid()).toBe(true)

  describe "errors", ->
    context "all provided numbers are valid", ->
      beforeEach ->
        @subject = factory()

      it "returns an empty array", ->
        expect(@subject.accountErrors()).toEqual([])
        expect(@subject.transitErrors()).toEqual([])
        expect(@subject.errors()).toEqual([])

    context "account number is invalid", ->
      beforeEach ->
        @subject = factory(account: "123")

      it "returns the right error", ->
        expect(@subject.accountErrors()).toEqual(["Bank of Montreal account number must be 7 digits long."])
        expect(@subject.transitErrors()).toEqual([])
        expect(@subject.errors()).toEqual(["Bank of Montreal account number must be 7 digits long."])

    context "transit number is invalid for BMO", ->
      beforeEach ->
        @subject = factory(transit: "123")

      it "returns the right error", ->
        expect(@subject.transitErrors()).toEqual(["Transit number must be 5 digits long."])
        expect(@subject.accountErrors()).toEqual([])
        expect(@subject.errors()).toEqual(["Transit number must be 5 digits long."])

    context "transit number is invalid for HSBC", ->
      beforeEach ->
        @subject = factory(institution: "016", transit: "123", account: "123456789")

      it "returns the right error", ->
        expect(@subject.transitErrors()).toEqual(["HSBC Bank of Canada transit number must begin with 10XXX."])
        expect(@subject.accountErrors()).toEqual([])
        expect(@subject.errors()).toEqual(["HSBC Bank of Canada transit number must begin with 10XXX."])

    context "transit number is invalid for an unknown bank", ->
      beforeEach ->
        @subject = factory(institution: "123", transit: "123")

      it "returns the right error", ->
        expect(@subject.transitErrors()).toEqual(["Transit number must be 5 digits long."])
