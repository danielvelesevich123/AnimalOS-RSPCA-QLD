# Summary of Salesforce Apex Testing and Deployment

## Target Org Alias

The target org alias for deploy and test commands is stored in **`.sf/config.json`** in the project root. Check the `target-org` key:

```json
{"target-org":"rspca-sa-staging"}
```

Use this value as `OrgAlias` in all `--target-org` parameters (e.g. `--target-org rspca-sa-staging`).

## 1. How to Deploy Updates

### Deploy Single Class

```bash
sf project deploy start --source-dir force-app/main/default/classes/ClassName.cls --target-org OrgAlias
```

### Deploy Multiple Classes

```bash
sf project deploy start --source-dir force-app/main/default/classes/Class1.cls --source-dir force-app/main/default/classes/Class1.cls-meta.xml --source-dir force-app/main/default/classes/Class2.cls --source-dir force-app/main/default/classes/Class2.cls-meta.xml --target-org OrgAlias
```

### Deploy Entire Project

```bash
sf project deploy start --target-org OrgAlias
```

## 2. How to Run Specific Tests and Check Coverage

### Run Specific Test Classes

```bash
sf apex run test --class-names TestClass1,TestClass2 --target-org OrgAlias --wait 5 --code-coverage
```

### Run All Tests

```bash
sf apex run test --target-org OrgAlias --wait 5 --code-coverage
```

### Check Coverage for Specific Classes

The coverage report shows:
- **PERCENT**: Coverage percentage for each class
- **UNCOVERED LINES**: Specific line numbers not covered
- **Target**: Aim for 75%+ coverage

## 3. How to Write Tests for SubmitProc and MetaProc

### SubmitProc Test Pattern

```apex
@IsTest
static void testSubmitProc() {
    SettingsService.settingsVar = TestFactory.initSettings();
    SettingsService.init();
    Test.startTest();

    aos_Response response = new SubmitProc().process(new Map<String, Object>{
        'param1' => 'value1',
        'param2' => 'value2'
    });
    
    Test.stopTest();
    System.assert(response.isValid, 'Response should be valid');
}
```

### MetaProc Test Pattern

```apex
@IsTest
static void testMetaProc() {
    SettingsService.settingsVar = TestFactory.initSettings();
    SettingsService.init();
    Test.startTest();

    aos_Response response = new MetaProc().process(new Map<String, Object>{
        'recordId' => testRecord.Id
    });
    
    Test.stopTest();
    System.assert(response.isValid, 'Response should be valid');
    System.assertNotEquals(null, response.get('data'), 'Data should be present');
}
```

## 4. How to Mock Endpoints

### Basic HTTP Mock

```apex
new HttpMock()
    .add('GET', 'https://api.stripe.com/v1/customers/cus_test', 200, new Map<String, Object>{
        'id' => 'cus_test',
        'object' => 'customer',
        'email' => 'test@example.com'
    })
    .setMock();
```

### Multiple Endpoints

```apex
new HttpMock()
    .add('POST', 'https://api.stripe.com/v1/plans', 200, new Map<String, Object>{
        'id' => 'plan_test',
        'amount' => 5000,
        'currency' => 'usd'
    })
    .add('POST', 'https://api.stripe.com/v1/subscriptions', 200, new Map<String, Object>{
        'id' => 'sub_test',
        'status' => 'active'
    })
    .setMock();
```

### Error Responses

```apex
new HttpMock()
    .add('POST', 'https://api.stripe.com/v1/refunds', 400, new Map<String, Object>{
        'error' => new Map<String, Object>{
            'message' => 'Refund failed',
            'type' => 'card_error'
        }
    })
    .setMock();
```

## 5. How to Create Sales-Related Test Data

### Complete Test Data Setup Pattern. Refer to objects folder in sfdx project to find all details about data model.

```apex
@TestSetup
static void setupTestData() {
    // Create test data following the pattern from StripeTest.testStripeCustomerSubscriptionUpdatedProc
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;
    
    Contact testContact = new Contact(
        AccountId = testAccount.Id,
        FirstName = 'Test',
        LastName = 'Contact'
    );
    insert testContact;
    
    Campaign testCampaign = new Campaign(
        Name = 'Test Campaign'
    );
    insert testCampaign;
    
    npe03__Recurring_Donation__c testRecurringDonation = new npe03__Recurring_Donation__c(
        Name = 'Test Recurring Donation',
        npe03__Contact__c = testContact.Id,
        npe03__Amount__c = 50,
        npe03__Installment_Period__c = 'Monthly',
        npe03__Recurring_Donation_Campaign__c = testCampaign.Id,
        Stripe_Subscription__c = 'sub_test_credit_card_123'
    );
    insert testRecurringDonation;
    
    Opportunity testOpp = new Opportunity(
        Name = 'Test Opportunity',
        npsp__Primary_Contact__c = testContact.Id,
        CampaignId = testCampaign.Id,
        npe03__Recurring_Donation__c = testRecurringDonation.Id,
        Amount = 50,
        StageName = 'Closed Won',
        CloseDate = Date.today()
    );
    insert testOpp;
    
    npe01__OppPayment__c payment = new npe01__OppPayment__c(
        npsp__Gateway_Payment_ID__c = 'pi_test',
        Gateway_Transaction_ID__c = 'ch_test_123',
        npe01__Payment_Amount__c = 100,
        npe01__Opportunity__c = testOpp.Id,
        npe01__Paid__c = true,
        npe01__Payment_Method__c = 'Credit Card'
    );
    insert payment;
}
```

## 6. How to Avoid Mixed DML Exception

### Problem

Cannot mix DML operations on setup objects (like `PermissionSetAssignment`, `EmailTemplate`, `OrgWideEmailAddress`) with non-setup objects (like `Account`, `Contact`) in the same transaction.

### Solution

Separate Setup and Non-Setup Data. Create Setup data in `@TestSetup` and Non-Setup data in test method.

```apex
@TestSetup
static void setupTestData() {
    // Create setup objects first (EmailTemplate, PermissionSetAssignment, etc.)
    EmailTemplate testTemplate = new EmailTemplate(
        Name = 'Test Template',
        DeveloperName = 'Test_Template',
        TemplateType = 'text',
        FolderId = UserInfo.getUserId()
    );
    insert testTemplate;
}

@IsTest
static void testMethodAny() {
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    Contact testContact = new Contact(
        AccountId = testAccount.Id,
        FirstName = 'Test',
        LastName = 'Contact'
    );
    insert testContact;
}
```

## Key Best Practices

1. **Use Test.startTest() and Test.stopTest()** around the main test logic if related apex class has asynchronous logic.
2. **Mock external API calls** to avoid real network requests
3. **Create comprehensive test data** that covers all scenarios
4. **Aim for 75%+ coverage** for each class
5. **Use descriptive test method names** that indicate what is being tested
6. **Include both positive and negative test cases**
7. **Do not use System.assert(true).**
