/*
2017-01-19 Alon Waisman
ctrl_CCT_Bulk_SMS - 100%
*/

@isTest
private class test_CCT_Bulk_SMS {

    static testMethod void test_coverage() {
        ctrl_CCT_Bulk_SMS controller = new ctrl_CCT_Bulk_SMS();
        system.assert(controller.getagents().size() > 0);

        controller.send_messages();
        system.assertEquals(160, controller.getcharacters_remaining());
        system.assertEquals('Whoops... the message is blank. Be sure to add a message before sending.', controller.response);

        controller.message = 'test';
        controller.send_messages();
        system.assertEquals(156, controller.getcharacters_remaining());
        system.assertEquals('SUCCESS! The messages are being sent.', controller.response);
    }

}