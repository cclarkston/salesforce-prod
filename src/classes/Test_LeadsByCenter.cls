/**********************************************************************************
Name    : Test_LeadsByCenter
Usage   : Test custom class/vf page code

CHANGE HISTORY
===============================================================================
DATE            NAME                  DESC
2011-03-16     Mike Merino            Initial release                

*************************************************************************************/
@isTest
private class Test_LeadsByCenter {
    public static testMethod void testMyController() {
      
      LeadsByCenter1 myTest = new LeadsByCenter1();

      myTest.getMyCollection1();
      myTest.getMyCollection2();
      myTest.getMyCollection3();
    }

}