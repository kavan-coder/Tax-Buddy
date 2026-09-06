import SwiftUI
import FirebaseAI
import PDFKit
enum FilingMode {
    case practice
    case real
}
struct FilingStep {
    let number: Int
    let title: String
    let instruction: String
    let definition: String
    let requiresInput: Bool
    let inputLabel: String
    let imageName: String
    
}
struct PracticeProfile {
    let firstName: String
    let lastName: String
    let ssn: String
    let addressLine1: String
    let cityStateZip: String
    let income: Double
    let federalTaxWithheld: Double
    let routingNumber: String
    let accountNumber: String
    let occupation: String

    var fullName: String {
        "\(firstName) \(lastName)"
    }

    static let samples: [PracticeProfile] = [
        PracticeProfile(
            firstName: "Avery",
            lastName: "Brooks",
            ssn: "531-84-2716",
            addressLine1: "1842 Maple Ridge Ave",
            cityStateZip: "Des Moines, IA 50309",
            income: 18400,
            federalTaxWithheld: 300,
            routingNumber: "071923284",
            accountNumber: "004582193761",
            occupation: "Barista"
        ),
        PracticeProfile(
            firstName: "Jordan",
            lastName: "Ramirez",
            ssn: "462-19-7804",
            addressLine1: "922 Harbor View St",
            cityStateZip: "Milwaukee, WI 53202",
            income: 22150,
            federalTaxWithheld: 640,
            routingNumber: "075000019",
            accountNumber: "009441726580",
            occupation: "Campus Bookstore Clerk"
        ),
        PracticeProfile(
            firstName: "Taylor",
            lastName: "Nguyen",
            ssn: "618-27-4905",
            addressLine1: "57 Cedar Park Ln",
            cityStateZip: "Springfield, IL 62704",
            income: 19875,
            federalTaxWithheld: 415,
            routingNumber: "071122661",
            accountNumber: "003817264905",
            occupation: "Lifeguard"
        ),
        PracticeProfile(
            firstName: "Morgan",
            lastName: "Patel",
            ssn: "483-61-2957",
            addressLine1: "311 Willow Creek Dr",
            cityStateZip: "Madison, WI 53703",
            income: 24500,
            federalTaxWithheld: 780,
            routingNumber: "075911988",
            accountNumber: "006251984372",
            occupation: "Library Assistant"
        ),
        PracticeProfile(
            firstName: "Cameron",
            lastName: "Lee",
            ssn: "574-33-9182",
            addressLine1: "780 Pine Hollow Rd",
            cityStateZip: "Ann Arbor, MI 48104",
            income: 17320,
            federalTaxWithheld: 210,
            routingNumber: "072000326",
            accountNumber: "001948275630",
            occupation: "Dog Walker"
        ),
        PracticeProfile(
            firstName: "Riley",
            lastName: "Johnson",
            ssn: "629-45-1708",
            addressLine1: "205 Lakeview Terrace",
            cityStateZip: "Minneapolis, MN 55408",
            income: 26840,
            federalTaxWithheld: 910,
            routingNumber: "091000019",
            accountNumber: "008315472609",
            occupation: "Retail Associate"
        ),
        PracticeProfile(
            firstName: "Skyler",
            lastName: "Hernandez",
            ssn: "512-98-3461",
            addressLine1: "44 Birch Point Ave",
            cityStateZip: "Omaha, NE 68102",
            income: 15890,
            federalTaxWithheld: 160,
            routingNumber: "104000016",
            accountNumber: "002716359480",
            occupation: "Cashier"
        ),
        PracticeProfile(
            firstName: "Peyton",
            lastName: "Kim",
            ssn: "691-24-5830",
            addressLine1: "990 Sunset Blvd",
            cityStateZip: "St. Louis, MO 63103",
            income: 31210,
            federalTaxWithheld: 1425,
            routingNumber: "081000210",
            accountNumber: "007824196305",
            occupation: "Dental Receptionist"
        ),
        PracticeProfile(
            firstName: "Logan",
            lastName: "Carter",
            ssn: "455-72-8149",
            addressLine1: "128 Meadow Run",
            cityStateZip: "Indianapolis, IN 46204",
            income: 20140,
            federalTaxWithheld: 520,
            routingNumber: "074000010",
            accountNumber: "005438271964",
            occupation: "Warehouse Helper"
        ),
        PracticeProfile(
            firstName: "Quinn",
            lastName: "Davis",
            ssn: "603-14-7528",
            addressLine1: "67 Riverfront Ct",
            cityStateZip: "Cincinnati, OH 45202",
            income: 22975,
            federalTaxWithheld: 695,
            routingNumber: "042000314",
            accountNumber: "009205471863",
            occupation: "Tutor"
        ),
        PracticeProfile(
            firstName: "Harper",
            lastName: "Flores",
            ssn: "546-89-2037",
            addressLine1: "843 Northfield Ave",
            cityStateZip: "Kansas City, KS 66101",
            income: 19060,
            federalTaxWithheld: 355,
            routingNumber: "101000695",
            accountNumber: "004127958630",
            occupation: "Bakery Clerk"
        ),
        PracticeProfile(
            firstName: "Emerson",
            lastName: "White",
            ssn: "677-30-4185",
            addressLine1: "512 Oak Crest Way",
            cityStateZip: "Tulsa, OK 74103",
            income: 27625,
            federalTaxWithheld: 1035,
            routingNumber: "103000648",
            accountNumber: "003694182750",
            occupation: "Medical Office Assistant"
        )
    ]
}
struct StepsView: View {
    let mode: FilingMode
    @Environment(\.dismiss) private var dismiss
    @AppStorage("showTaxBuddyCelebration") private var showCelebration = false
    private let standardDeductionAmount = 15750.0
    private let model = FirebaseAI.firebaseAI(backend: .googleAI())
        .generativeModel(modelName: "gemini-2.5-flash")
    @State private var taxableIncome = ""
    @State private var enteredIncome = ""
    @State private var enteredWithholding = ""
    @State private var savedTaxableIncome = ""
    @State private var aiResponse = ""
    @State private var isLoading = false
    @State private var pdfText = ""
    @State private var currentStep = 1
    @State private var practiceProfile = PracticeProfile.samples[0]
    private var practiceSteps: [FilingStep] {
        let profile = practiceProfile
        let incomeText = formatCurrency(profile.income)
        let withheldText = formatCurrency(profile.federalTaxWithheld)
        let taxableIncome = max(profile.income - standardDeductionAmount, 0)
        let taxableIncomeText = formatCurrency(taxableIncome)
        let refundPrompt = practiceRefundEstimateText()
        let hasOverpayment = practiceHasOverpayment ?? true

        var steps: [FilingStep] = [
            FilingStep(number: 1, title: "Meet Your Practice Filer", instruction: "Download and Print out a **Form 1040** from the IRS Website. Click on the link below.", definition: "A **W-2** shows money earned from a job and tax already taken out. A **Form 1040** is the main tax form you fill out.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 2, title: "Personal Info", instruction: "Enter **\(profile.fullName)**, **SSN \(profile.ssn)**, and **\(profile.addressLine1), \(profile.cityStateZip)** into the personal information section of the return.", definition: "The top of the return identifies who is filing. In this lesson, you practice placing a filer’s legal name, Social Security number, and address in the correct spots.", requiresInput: false, inputLabel: "", imageName: "Step_2"),
            FilingStep(number: 3, title: "Box 1a - Income", instruction: "Use the fake W-2 income amount **\(incomeText)** for **\(profile.fullName)** and place that number into **Box 1a**.", definition: "This is the total money the filer made from work for the year. You start the tax form with this number.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 4, title: "Box 9 - Total Income", instruction: "Because this practice filer has one income source, copy **\(incomeText)** into **Box 9**.", definition: "Total income combines income sources before deductions. In a simple return, it can match the wage amount from Box 1a.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 5, title: "Box 11a - Adjusted Gross Income", instruction: "No adjustments apply in this practice case, so **Box 11a = \(incomeText)**.", definition: "Adjusted Gross Income, or AGI, is income after eligible adjustments. It usually stays the same as total income.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 6, title: "Box 11b - Adjusted Gross Income", instruction: "Copy **\(incomeText)** from **Box 11a** into **Box 11b**.", definition: "This step carries AGI forward so the next deduction and tax calculations stay consistent.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 7, title: "Box 12e - Standard Deduction", instruction: "Use the single-filer standard deduction of **\(formatCurrency(standardDeductionAmount))** in **Box 12e**.", definition: "The standard deduction lowers the amount of income that will actually be taxed.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 8, title: "Box 15 - Taxable Income", instruction: "Subtract the standard deduction from AGI: **\(incomeText) - \(formatCurrency(standardDeductionAmount)) = \(taxableIncomeText)**. Put **\(taxableIncomeText)** in **Box 15**.", definition: "Taxable income is the amount left after deductions. It is the number used to estimate tax owed.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 9, title: "Box 16 - Tax You Owe", instruction: "Tax Buddy will use the fake taxable income for **\(profile.fullName)** and the tax reference to estimate the amount for **Box 16**.", definition: "Box 16 is the estimated federal tax based on taxable income and the tax instructions.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 10, title: "Box 24 - Total Tax", instruction: "Copy the amount below to **Box 24**.", definition: "Total tax is the return’s full tax amount before deductions.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 11, title: "Box 25a - Federal Tax Withheld", instruction: "Use the fake withheld amount **\(withheldText)** from the sample W-2 and enter it into **Box 25a**.", definition: "Federal tax withheld is money already sent to the IRS from paychecks during the year.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 12, title: "Box 25d - Total Tax Paid", instruction: "Copy the same withheld amount **\(withheldText)** into **Box 25d** and **Box 33**.", definition: "This step totals the tax already paid toward the return.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 13, title: "Box 34 - Amount Overpaid", instruction: refundPrompt, definition: "An overpayment happens when the filer already paid more tax than they owed.", requiresInput: false, inputLabel: "", imageName: "")
        ]

        if hasOverpayment {
            steps.append(contentsOf: [
                FilingStep(number: 14, title: "Box 35a - Amount Wanted Back", instruction: "If the practice filer overpaid, copy that same refund amount into **Box 35a**.", definition: "Box 35a is where the filer asks to have an overpayment refunded.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 15, title: "Box 35b - Routing Number", instruction: "Use the fake routing number **\(profile.routingNumber)** from the sample bank information.", definition: "A routing number identifies the bank that should receive the direct deposit.", requiresInput: false, inputLabel: "", imageName: "Step_15"),
                FilingStep(number: 16, title: "Box 35c - Account Type", instruction: "Choose **checking** for this practice filer’s refund account.", definition: "Account type tells the IRS whether the refund should go to a checking or savings account.", requiresInput: false, inputLabel: "", imageName: "Step_16"),
                FilingStep(number: 17, title: "Box 35d - Account Number", instruction: "Use the fake account number **\(profile.accountNumber)** from the sample bank information.", definition: "The account number points to the exact bank account that would receive the refund.", requiresInput: false, inputLabel: "", imageName: "Step_17"),
                FilingStep(number: 18, title: "Signature", instruction: "**\(profile.fullName)** would sign the return, add today’s date, and list the occupation **\(profile.occupation)**.", definition: "The signature section confirms the return is complete and ready to file.", requiresInput: false, inputLabel: "", imageName: "Step_18")
            ])
        } else {
            steps.append(contentsOf: [
                FilingStep(number: 14, title: "Box 37 - Amount You Owe", instruction: "Because the estimated tax is higher than what was withheld, enter the amount owed on **Box 37** instead of filling out the refund section.", definition: "Box 37 is used when the filer still owes money to the IRS after subtracting withholding from total tax.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 15, title: "Signature", instruction: "**\(profile.fullName)** would sign the return, add today’s date, and list the occupation **\(profile.occupation)**.", definition: "The signature section confirms the return is complete and ready to file.", requiresInput: false, inputLabel: "", imageName: "Step_18")
            ])
        }

        return steps
    }
    private var realSteps: [FilingStep] {
        let hasOverpayment = realHasOverpayment ?? true
        var steps: [FilingStep] = [
            FilingStep(number: 1, title: "Documents Needed", instruction: """
Have these documents ready with you for your tax return:

#1 [Form 1040](https://www.irs.gov/pub/irs-pdf/f1040.pdf) - Click on the hyperlink to access the form.

#2 W-2 - This is given by your employer.

#3 Bank Info - You need to get your account number and routing number. Contact your bank to get these numbers or access it from your bank mobile app.

You will ONLY be filling out Form 1040.
""", definition: "These papers give you the numbers you need to fill out your tax return.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 2, title: "Personal Info", instruction: """
#1 **Write your name, SSN, and address on the Form 1040.**

#2 **Then enter your yearly income from W-2 Box 1 below so Tax Buddy can help with the next steps.**
""", definition: "Your tax form needs your basic info, and your yearly income is the main number used in the rest of the return.", requiresInput: true, inputLabel: "Enter yearly income from W-2 Box 1", imageName: ""),
            FilingStep(number: 3, title: "Box 1a - Yearly Income", instruction: "Re-enter the income amount shown below into **Box 1a** on the Form 1040.", definition: "This is the money you made from work this year.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 4, title: "Box 9 - Total Income", instruction: "Copy the same amount into **Box 9**.", definition: "This is your income total so far.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 5, title: "Box 11a - Adjusted Gross Income", instruction: "Copy the same amount into **Box 11a**.", definition: "This is your income after small changes. For a simple return, it usually stays the same.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 6, title: "Box 11b - Adjusted Gross Income", instruction: "Copy the same amount into **Box 11b**.", definition: "This keeps your form numbers matching.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 7, title: "Box 12e - Standard Deduction", instruction: "Enter **$15,750** into **Box 12e**.", definition: "This lowers the amount of income that can be taxed. This amount is valid for the current Tax Year.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 8, title: "Box 15 - Taxable Income", instruction: "Tax Buddy will subtract the standard deduction so you can copy the amount into **Box 15**.", definition: "This is the part of your income that gets taxed.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 9, title: "Box 16 - Tax You Owe", instruction: "Tax Buddy is calculating the amount of tax you owe for **Box 16**.", definition: "This is an estimate of your federal tax.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 10, title: "Box 24 - Total Tax", instruction: "Copy the amount shown below into **Box 24**.", definition: "This is your total tax before comparing it to what you already paid.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 11, title: "Box 25a - Taxes Paid", instruction: "Find **W-2 Box 2** and enter that number below.", definition: "This is the tax already taken out of your paychecks.", requiresInput: true, inputLabel: "Enter W-2 Box 2 amount", imageName: ""),
            FilingStep(number: 12, title: "Box 25d - Total Tax Paid", instruction: "Copy that same number into **Box 25d** and **Box 33**.", definition: "This shows how much tax was already paid.", requiresInput: false, inputLabel: "", imageName: ""),
            FilingStep(number: 13, title: "Box 34 - Amount Overpaid", instruction: realRefundEstimateText(), definition: "This step checks if you paid too much tax during the year.", requiresInput: false, inputLabel: "", imageName: "")
        ]

        if hasOverpayment {
            steps.append(contentsOf: [
                FilingStep(number: 14, title: "Box 35a - Amount Wanted Back", instruction: "Copy the refund amount from **Box 34** into **Box 35a**.", definition: "This is the money the IRS would send back to you.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 15, title: "Box 35b - Routing Number", instruction: "Find your routing number on your bank statement and write it on the form.", definition: "A routing number tells the IRS which bank to send your refund to.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 16, title: "Box 35c - Account Type", instruction: "Choose your account type, usually **checking**.", definition: "This tells the IRS what kind of bank account you use.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 17, title: "Box 35d - Account Number", instruction: "Find your account number on your bank statement and write it on the form.", definition: "This tells the IRS which exact account should get the refund.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 18, title: "Signature", instruction: "Sign the form, add today’s date, and write your job or occupation.", definition: "Your signature says the form is complete and honest.", requiresInput: false, inputLabel: "", imageName: "")
            ])
        } else {
            steps.append(contentsOf: [
                FilingStep(number: 14, title: "Box 37 - Amount You Owe", instruction: "If you still owe tax, put that amount in **Box 37**.", definition: "This is the money still owed to the IRS.", requiresInput: false, inputLabel: "", imageName: ""),
                FilingStep(number: 15, title: "Signature", instruction: "Sign the form, add today’s date, and write your job or occupation.", definition: "Your signature says the form is complete and honest.", requiresInput: false, inputLabel: "", imageName: "")
            ])
        }

        return steps
    }
    private var activeSteps: [FilingStep] {
        isRealMode ? realSteps : practiceSteps
    }
    private var currentActiveStep: FilingStep {
        activeSteps[min(max(currentStep, 1), activeSteps.count) - 1]
    }
    private var currentRealStep: FilingStep {
        realSteps[min(max(currentStep, 1), realSteps.count) - 1]
    }
    private var isRealMode: Bool {
        mode == .real
    }
    private var inputEnabled: Bool {
        currentActiveStep.requiresInput
    }
    private var nextButtonDisabled: Bool {
        if isLoading || pdfText.isEmpty { return true }
        if inputEnabled {
            return taxableIncome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }
    private var backButtonDisabled: Bool {
        isLoading || currentStep <= 1
    }
    private var displayStepNumber: Int {
        currentActiveStep.number
    }
    private var formattedTaxOwed: String {
        guard let number = Double(aiResponse.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")) else {
            return aiResponse
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = number.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: number)) ?? aiResponse
    }
    private var practiceTaxableIncome: Double {
        max(practiceProfile.income - standardDeductionAmount, 0)
    }
    private var practiceHasOverpayment: Bool? {
        guard let estimatedTax = parseCurrencyString(aiResponse) else { return nil }
        return practiceProfile.federalTaxWithheld >= estimatedTax
    }
    private var realHasOverpayment: Bool? {
        guard let estimatedTax = parseCurrencyString(aiResponse),
              let withheld = parseCurrencyString(enteredWithholding) else { return nil }
        return withheld >= estimatedTax
    }
    private var cleanedEnteredWithholding: Double? {
        parseCurrencyString(enteredWithholding)
    }
    private var cleanedEnteredIncome: Double? {
        parseCurrencyString(enteredIncome)
    }
    private var computedRealStepValue: String? {
        guard isRealMode else { return nil }
        switch currentActiveStep.number {
        case 2, 3, 4, 5, 6:
            guard let income = cleanedEnteredIncome else { return nil }
            return formatCurrency(income)
        case 7:
            return formatCurrency(standardDeductionAmount)
        case 8:
            guard let income = cleanedEnteredIncome else { return nil }
            return formatCurrency(max(income - standardDeductionAmount, 0))
        case 10:
            guard !aiResponse.isEmpty else { return nil }
            return formattedTaxOwed
        case 12:
            guard let withheld = cleanedEnteredWithholding else { return nil }
            return formatCurrency(withheld)
        case 13:
            guard let estimatedTax = parseCurrencyString(aiResponse),
                  let withheld = cleanedEnteredWithholding else { return nil }
            return formatCurrency(max(withheld - estimatedTax, 0))
        case 14 where realHasOverpayment == false:
            guard let estimatedTax = parseCurrencyString(aiResponse),
                  let withheld = cleanedEnteredWithholding else { return nil }
            return formatCurrency(max(estimatedTax - withheld, 0))
        case 14 where realHasOverpayment == true:
            guard let estimatedTax = parseCurrencyString(aiResponse),
                  let withheld = cleanedEnteredWithholding else { return nil }
            return formatCurrency(max(withheld - estimatedTax, 0))
        default:
            return nil
        }
    }
    private var computedPracticeStepValue: String? {
        guard !isRealMode else { return nil }
        switch currentActiveStep.number {
        case 2:
            return "\(practiceProfile.fullName)\nSSN \(practiceProfile.ssn)\n\(practiceProfile.addressLine1)\n\(practiceProfile.cityStateZip)"
        case 3, 4, 5, 6:
            return formatCurrency(practiceProfile.income)
        case 7:
            return formatCurrency(standardDeductionAmount)
        case 8:
            return formatCurrency(practiceTaxableIncome)
        case 10:
            guard !aiResponse.isEmpty else { return nil }
            return formattedTaxOwed
        case 11, 12:
            return formatCurrency(practiceProfile.federalTaxWithheld)
        case 13:
            guard let estimatedTax = parseCurrencyString(aiResponse) else { return nil }
            return formatCurrency(max(practiceProfile.federalTaxWithheld - estimatedTax, 0))
        case 14 where practiceHasOverpayment == true:
            guard let estimatedTax = parseCurrencyString(aiResponse) else { return nil }
            return formatCurrency(max(practiceProfile.federalTaxWithheld - estimatedTax, 0))
        case 14:
            guard let estimatedTax = parseCurrencyString(aiResponse),
                  practiceHasOverpayment == false else { return nil }
            return formatCurrency(max(estimatedTax - practiceProfile.federalTaxWithheld, 0))
        case 15 where practiceHasOverpayment == true:
            return practiceProfile.routingNumber
        case 16 where practiceHasOverpayment == true:
            return "Checking"
        case 17 where practiceHasOverpayment == true:
            return practiceProfile.accountNumber
        default:
            return nil
        }
    }
    private var computedPracticeStepLabel: String? {
        guard !isRealMode else { return nil }
        switch currentActiveStep.number {
        case 2:
            return "Enter These Details"
        case 3:
            return "Box 1a Amount"
        case 4:
            return "Box 9 Amount"
        case 5:
            return "Box 11a Amount"
        case 6:
            return "Box 11b Amount"
        case 7:
            return "Box 12e Amount"
        case 8:
            return "Box 15 Amount"
        case 10:
            return "Box 24 Amount"
        case 11:
            return "Box 25a Amount"
        case 12:
            return "Box 25d / Box 33 Amount"
        case 13:
            return "Box 34 Amount"
        case 14 where practiceHasOverpayment == true:
            return "Box 35a Amount"
        case 14 where practiceHasOverpayment == false:
            return "Box 37 Amount"
        case 15 where practiceHasOverpayment == true:
            return "Routing Number"
        case 16 where practiceHasOverpayment == true:
            return "Account Type"
        case 17 where practiceHasOverpayment == true:
            return "Account Number"
        default:
            return nil
        }
    }
    private var practiceCardUsesLargeNumberStyle: Bool {
        guard !isRealMode else { return false }
        switch currentActiveStep.number {
        case 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14:
            return true
        default:
            return false
        }
    }
    private var computedRealStepLabel: String? {
        guard isRealMode else { return nil }
        switch currentActiveStep.number {
        case 2:
            return "Yearly Income"
        case 3:
            return "Box 1a Amount"
        case 4:
            return "Box 9 Amount"
        case 5:
            return "Box 11a Amount"
        case 6:
            return "Box 11b Amount"
        case 7:
            return "Box 12e Amount"
        case 8:
            return "Box 15 Amount"
        case 10:
            return "Box 24 Amount"
        case 12:
            return "Box 25d / Box 33 Amount"
        case 13:
            return "Box 34 Amount"
        case 14 where realHasOverpayment == false:
            return "Line 37 Amount"
        case 14 where realHasOverpayment == true:
            return "Box 35a Amount"
        default:
            return nil
        }
    }
    private var contentSpacing: CGFloat {
        isRealMode ? 20 : 12
    }
    private var contentPadding: CGFloat {
        isRealMode ? 24 : 16
    }
    private var lessonCardPadding: CGFloat {
        isRealMode ? 16 : 12
    }
    private var practiceAccent: Color {
        Color(red: 0.17, green: 0.66, blue: 0.42)
    }
    private var practiceAccentSoft: Color {
        Color(red: 0.89, green: 0.97, blue: 0.91)
    }
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.76, green: 0.90, blue: 0.99),
                    Color(red: 0.68, green: 0.86, blue: 0.98)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            VStack(spacing: isRealMode ? 22 : 14) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.28))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.16), lineWidth: 1.2)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }

                    Spacer()
                }
                .padding(.top, 22)

                Text("Tax Buddy")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                if !isRealMode {
                    VStack(spacing: 6) {
                        Text("Practice Mode")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(practiceAccent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(practiceAccentSoft)
                            .clipShape(Capsule())

                        Text("Learn each line, then copy the number with confidence.")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.18, green: 0.29, blue: 0.22))
                            .multilineTextAlignment(.center)
                    }
                }
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.26))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.16), lineWidth: 1.4)
                    )
                    .frame(height: 62)
                    .overlay {
                        Text("Step \(displayStepNumber)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                    }
                    .padding(.top, 10)
                ZStack {
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.white.opacity(0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.black.opacity(0.16), lineWidth: 1.6)
                        )
                    GeometryReader { geometry in
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .center, spacing: contentSpacing) {
                                Text(currentActiveStep.title)
                                    .font(.system(size: isRealMode ? 26 : 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                                    .multilineTextAlignment(.center)

                                if isRealMode && currentActiveStep.number == 2 {
                                    ZoomablePracticeImage(imageName: "Step_3_R")
                                        .frame(maxHeight: 170)
                                }

                                if isRealMode && currentActiveStep.number == 11 {
                                    ZoomablePracticeImage(imageName: "Step_11_R")
                                        .frame(maxHeight: 170)
                                }

                                if !isRealMode, !currentActiveStep.imageName.isEmpty {
                                    ZoomablePracticeImage(imageName: currentActiveStep.imageName)
                                        .frame(maxHeight: (currentActiveStep.number == 2 || currentActiveStep.number == 3) ? 255 : 128)

                                    if currentActiveStep.number == 12 {
                                        ZoomablePracticeImage(imageName: "Step_12(2)")
                                            .frame(maxHeight: 128)
                                    }
                                }

                                if !isRealMode && currentActiveStep.number == 1 {
                                    PracticeProfileCard(profile: practiceProfile)
                                }
                                
                                if isRealMode || currentActiveStep.number != 2 {
                                    VStack(alignment: .center, spacing: 7) {
                                        lessonHeader("What to do", isPractice: !isRealMode)
                                        if isRealMode {
                                            lessonText(
                                                stepInstructionText(),
                                                size: 18,
                                                weight: .medium,
                                                color: Color(red: 0.16, green: 0.22, blue: 0.30),
                                                alignment: currentActiveStep.number == 1 || currentActiveStep.number == 2 ? .leading : .center,
                                                preserveParagraphs: currentActiveStep.number == 1 || currentActiveStep.number == 2
                                            )
                                            if currentActiveStep.number == 9 {
                                                Text("This number is a helpful estimate. If you want to be extra sure everything is right, it can help to check with a CPA, tax attorney, or trusted adult before filing.")
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(Color(red: 0.70, green: 0.23, blue: 0.18))
                                                    .lineSpacing(3)
                                                    .multilineTextAlignment(.center)
                                                    .padding(.top, 6)
                                            }
                                        } else {
                                            lessonText(stepInstructionText(), size: 18, weight: .medium, color: Color(red: 0.16, green: 0.22, blue: 0.30))
                                            if currentActiveStep.number == 1,
                                               let form1040URL = URL(string: "https://www.irs.gov/pub/irs-pdf/f1040.pdf") {
                                                Link("Open Form 1040", destination: form1040URL)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundStyle(practiceAccent)
                                                    .padding(.top, 4)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(lessonCardPadding)
                                    .background(isRealMode ? Color.white.opacity(0.18) : practiceAccentSoft.opacity(0.92))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(isRealMode ? Color.black.opacity(0.08) : practiceAccent.opacity(0.18), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                if (isRealMode && currentActiveStep.number != 2) || (!isRealMode && currentActiveStep.number != 2 && currentActiveStep.number != 3) {
                                    VStack(alignment: .center, spacing: 7) {
                                        lessonHeader("What this means", isPractice: !isRealMode)
                                        lessonText(currentActiveStep.definition, size: 17, weight: .medium, color: Color(red: 0.20, green: 0.26, blue: 0.35))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(lessonCardPadding)
                                    .background(isRealMode ? Color.white.opacity(0.18) : Color.white.opacity(0.36))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(isRealMode ? Color.black.opacity(0.08) : practiceAccent.opacity(0.14), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                if let computedLabel = computedRealStepLabel, let computedValue = computedRealStepValue {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text(computedLabel)
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                        Text(computedValue)
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(red: 0.80, green: 0.18, blue: 0.20))
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.white.opacity(0.30))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                if let computedLabel = computedPracticeStepLabel, let computedValue = computedPracticeStepValue {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text(computedLabel)
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                        Text(computedValue)
                                            .font(.system(size: practiceCardUsesLargeNumberStyle ? 36 : 21, weight: .bold, design: .rounded))
                                            .foregroundColor(practiceAccent)
                                            .frame(maxWidth: .infinity)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(practiceAccentSoft.opacity(0.98))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(practiceAccent.opacity(0.22), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                                if currentActiveStep.number == 9 && !aiResponse.isEmpty {
                                    VStack(alignment: .center, spacing: 10) {
                                        Text(isRealMode ? "Estimated Tax Owed" : "Practice Tax Result")
                                            .font(.headline.weight(.bold))
                                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                        Text(formattedTaxOwed)
                                            .font(.system(size: 36, weight: .bold, design: .rounded))
                                            .foregroundColor(isRealMode ? Color(red: 0.80, green: 0.18, blue: 0.20) : practiceAccent)
                                            .frame(maxWidth: .infinity)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(16)
                                    .frame(maxWidth: .infinity)
                                    .background(isRealMode ? Color.white.opacity(0.30) : practiceAccentSoft.opacity(0.98))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(isRealMode ? Color.clear : practiceAccent.opacity(0.22), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: geometry.size.height - 48, alignment: .center)
                            .padding(contentPadding)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                VStack(spacing: isRealMode ? 14 : 10) {
                    if inputEnabled {
                        TextField(currentActiveStep.inputLabel, text: $taxableIncome)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.30))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.black.opacity(0.16), lineWidth: 1.3)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .keyboardType(.decimalPad)
                            .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                            .onChange(of: taxableIncome) { newValue in
                                guard isRealMode else { return }
                                let cleanedValue = numericInput(from: newValue)
                                if cleanedValue != newValue {
                                    taxableIncome = cleanedValue
                                }
                            }
                    }
                    HStack(spacing: isRealMode ? 18 : 12) {
                        Button {
                            handleBack()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.24))
                                    .frame(width: 112, height: 56)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.black.opacity(0.16), lineWidth: 1.3)
                                    )
                                Text("Back")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                            }
                        }
                        .disabled(backButtonDisabled)
                        .opacity(backButtonDisabled ? 0.55 : 1)
                        Button {
                            handleNext()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(mode == .practice ? practiceAccent : Color(red: 0.94, green: 0.34, blue: 0.34))
                                    .frame(width: 126, height: 56)
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(currentStep == activeSteps.count ? "Finish" : "Next")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .disabled(nextButtonDisabled)
                        .opacity(nextButtonDisabled ? 0.7 : 1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.bottom, isRealMode ? 4 : 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, isRealMode ? 20 : 14)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if !isRealMode {
                practiceProfile = PracticeProfile.samples.randomElement() ?? PracticeProfile.samples[0]
            }
            loadBundledPDF()
        }
    }
    private func stepInstructionText() -> String {
        if currentActiveStep.number == 9 && !aiResponse.isEmpty {
            if isRealMode {
                return "Tax Buddy has calculated the amount of tax owed below. Please enter it in **Box 16**."
            }
            return "Tax Buddy has calculated the sample tax amount for \(practiceProfile.firstName) based on the taxable income from Step 8."
        }
        return currentActiveStep.instruction
    }
    func loadBundledPDF() {
        guard let url = Bundle.main.url(forResource: "tax analysis", withExtension: "pdf") else {
            aiResponse = "PDF not found in bundle."
            return
        }
        guard let document = PDFDocument(url: url) else {
            aiResponse = "Failed to read PDF."
            return
        }
        var text = ""
        for i in 0..<document.pageCount {
            if let page = document.page(at: i), let pageText = page.string {
                text += pageText + "\n"
            }
        }
        pdfText = text
    }
    private func handleBack() {
        if currentStep > 1 {
            currentStep -= 1
        }
        if currentStep < 9 {
            aiResponse = ""
        }
        if isRealMode && currentStep == 2 {
            taxableIncome = enteredIncome
        } else if isRealMode && currentStep == 11 {
            taxableIncome = enteredWithholding
        } else if currentStep == 8 {
            taxableIncome = savedTaxableIncome
        }
    }
    private func handleNext() {
        if currentStep == activeSteps.count {
            showCelebration = true
            dismiss()
            return
        }
        if isRealMode && currentActiveStep.number == 2 {
            enteredIncome = taxableIncome
            savedTaxableIncome = taxableIncome
            taxableIncome = ""
            currentStep += 1
            return
        }
        if isRealMode && currentActiveStep.number == 11 {
            enteredWithholding = taxableIncome
            taxableIncome = ""
            currentStep += 1
            return
        }
        if currentActiveStep.number == 8 {
            if isRealMode {
                savedTaxableIncome = computedRealTaxableIncomeString()
            } else {
                savedTaxableIncome = String(format: "%.2f", practiceTaxableIncome)
            }
            taxableIncome = ""
            currentStep = 9
            if isRealMode {
                calculateRealTax()
            } else {
                calculatePracticeTax()
            }
            return
        }
        if currentStep < activeSteps.count {
            currentStep += 1
        }
    }
    private func calculatePracticeTax() {
        let cleanedIncome = savedTaxableIncome
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = """
        Use the following tax document to calculate the tax owed.
        The user is practicing with sample numbers for learning purposes.
        The taxable income is: \(cleanedIncome)
        Return only one number.
        No explanation.
        DOCUMENT:
        \(pdfText)
        """
        isLoading = true
        Task {
            do {
                let response = try await model.generateContent(prompt)
                let rawText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No response found"
                aiResponse = extractNumber(from: rawText)
            } catch {
                aiResponse = "Error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    private func calculateRealTax() {
        let cleanedIncome = savedTaxableIncome
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let prompt = """
        Use the following tax document to calculate the tax owed.
        The user is filing their own taxes.
        The taxable income is: \(cleanedIncome)
        Return only one number.
        No explanation.
        DOCUMENT:
        \(pdfText)
        """
        isLoading = true
        Task {
            do {
                let response = try await model.generateContent(prompt)
                let rawText = response.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No response found"
                aiResponse = extractNumber(from: rawText)
            } catch {
                aiResponse = "Error: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    func extractNumber(from text: String) -> String {
        let pattern = #"\d+(?:\.\d+)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range),
           let matchRange = Range(match.range, in: text) {
            return String(text[matchRange])
        }
        return text
    }
    private func parseCurrencyString(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned)
    }
    private func numericInput(from text: String) -> String {
        var result = ""
        var hasDecimalPoint = false

        for character in text {
            if character.isNumber {
                result.append(character)
            } else if character == "." && !hasDecimalPoint {
                result.append(character)
                hasDecimalPoint = true
            }
        }

        return result
    }
    private func formatCurrency(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = number.truncatingRemainder(dividingBy: 1) == 0 ? 0 : 2
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    private func computedRealTaxableIncomeString() -> String {
        guard let income = cleanedEnteredIncome else { return "" }
        return String(format: "%.2f", max(income - standardDeductionAmount, 0))
    }
    private func practiceRefundEstimateText() -> String {
        let withheldText = formatCurrency(practiceProfile.federalTaxWithheld)
        guard let estimatedTax = Double(aiResponse.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")) else {
            return "After you reach Step 9, compare the fake withholding **\(withheldText)** against the estimated tax from **Box 16** to see whether the filer overpaid."
        }

        let difference = practiceProfile.federalTaxWithheld - estimatedTax
        if difference >= 0 {
            return "Subtract the estimated **Box 16** tax from the withheld amount **\(withheldText)**. The practice filer overpaid **\(formatCurrency(difference))**, so that goes in **Box 34**."
        }

        return "The estimated **Box 16** tax is higher than the withheld amount **\(withheldText)**, so this practice filer does not have an overpayment for **Box 34**."
    }
    private func realRefundEstimateText() -> String {
        guard let withheld = cleanedEnteredWithholding else {
            return "After Step 11, compare **Box 33** and **Box 24** to see if you paid too much tax."
        }
        let withheldText = formatCurrency(withheld)
        guard let estimatedTax = parseCurrencyString(aiResponse) else {
            return "Compare **Box 33** **\(withheldText)** with **Box 24** to see if you paid too much tax."
        }
        let difference = withheld - estimatedTax
        if difference >= 0 {
            return "Subtract **Box 24** from **Box 33**. If you get **\(formatCurrency(difference))**, put that in **Box 34**."
        }
        return "**Box 24** is bigger than **Box 33**, so you do not have an overpayment for **Box 34**."
    }
    @ViewBuilder
    private func lessonText(
        _ content: String,
        size: CGFloat,
        weight: Font.Weight,
        color: Color,
        alignment: TextAlignment = .center,
        preserveParagraphs: Bool = false
    ) -> some View {
        let paragraphs = preserveParagraphs
            ? content.components(separatedBy: "\n\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            : [content]

        VStack(alignment: alignment == .leading ? .leading : .center, spacing: preserveParagraphs ? 12 : 0) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                let trimmedParagraph = paragraph.trimmingCharacters(in: .whitespacesAndNewlines)
                if let attributed = try? AttributedString(markdown: trimmedParagraph) {
                    Text(attributed)
                        .font(.system(size: size, weight: weight))
                        .foregroundColor(color)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
                        .multilineTextAlignment(alignment)
                } else {
                    Text(trimmedParagraph)
                        .font(.system(size: size, weight: weight))
                        .foregroundColor(color)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
                        .multilineTextAlignment(alignment)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }
    @ViewBuilder
    private func lessonHeader(_ title: String, isPractice: Bool) -> some View {
        if isPractice {
            HStack(spacing: 8) {
                Circle()
                    .fill(practiceAccent)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Text(title)
                .font(.headline.weight(.bold))
                .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }
}

private struct PracticeProfileCard: View {
    let profile: PracticeProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Fake Practice Filer")
                .font(.headline.weight(.bold))
                .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))

            PracticeProfileRow(label: "Name", value: profile.fullName)
            PracticeProfileRow(label: "SSN", value: profile.ssn)
            PracticeProfileRow(label: "Address", value: "\(profile.addressLine1), \(profile.cityStateZip)")
            PracticeProfileRow(label: "Income", value: currencyString(profile.income))
            PracticeProfileRow(label: "Fed Tax Withheld", value: currencyString(profile.federalTaxWithheld))
            PracticeProfileRow(label: "Routing", value: profile.routingNumber)
            PracticeProfileRow(label: "Account", value: profile.accountNumber)

            Text("All data shown here is fake and only for learning.")
                .font(.footnote.weight(.medium))
                .foregroundColor(Color(red: 0.30, green: 0.39, blue: 0.48))
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.white.opacity(0.34))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func currencyString(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

private struct PracticeProfileRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.bold))
                .foregroundColor(Color(red: 0.10, green: 0.16, blue: 0.22))
                .frame(width: 102, alignment: .leading)

            Text(value)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(red: 0.20, green: 0.26, blue: 0.35))
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
    }
}

private struct ZoomablePracticeImage: View {
    let imageName: String
    @State private var currentScale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(currentScale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                currentScale = min(max(1.0, lastScale * value), 4.0)
                            }
                            .onEnded { _ in
                                lastScale = currentScale
                            }
                    )
                    .animation(.easeInOut(duration: 0.15), value: currentScale)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                    VStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(Color.orange)
                        Text("Missing image: \(imageName)")
                            .font(.footnote)
                            .foregroundColor(Color(red: 0.20, green: 0.26, blue: 0.35))
                    }
                    .padding(12)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        StepsView(mode: .practice)
    }
}
