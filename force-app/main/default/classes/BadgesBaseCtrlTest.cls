/**
 * Created by golub on 24.11.2020.
 */

@IsTest
private class BadgesBaseCtrlTest {
    @IsTest
    static void testEmptyConstructor() {
        BadgesBaseCtrl.Badge badge = new BadgesBaseCtrl.Badge();
        System.assertEquals(null, badge.recordId );
    }

    @IsTest
    static void testConstructorWithTwoParameters(){
        String sldsIconName = 'add';
        String title = 'testTitle';

        BadgesBaseCtrl.Badge badge = new BadgesBaseCtrl.Badge(sldsIconName, title);

        System.assertEquals(sldsIconName, badge.sldsIconName);
        System.assertEquals(title, badge.title);
    }

    @IsTest
    static void testConstructorWithForParameters(){
        String sldsIconName = 'add';
        String title = 'testTitle';
        String type = 'testType';

        Account account = new Account(Name = 'testName');
        insert account;
        Contact contact = new Contact(
                FirstName = 'test',
                LastName = 'test',
                AccountId = account.Id
        );
        insert contact;

        BadgesBaseCtrl.Badge badge = new BadgesBaseCtrl.Badge(sldsIconName, title, type, contact.Id);

        System.assertEquals(sldsIconName, badge.sldsIconName);
        System.assertEquals(title, badge.title);
        System.assertEquals(type, badge.type);
        System.assertEquals(contact.Id, badge.recordId);
    }

    @IsTest
    static void testBadgesResponse(){
        BadgesBaseCtrl.Badge badge = new BadgesBaseCtrl.Badge();

        BadgesBaseCtrl.BadgesResponse badgesResponse = new BadgesBaseCtrl.BadgesResponse();
        badgesResponse.badges.add(badge);

        System.assertEquals(false, badgesResponse.badges.isEmpty());
    }
}