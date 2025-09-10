@isTest
public with sharing class vertic_FlowProcTest {

    @isTest
    private static void test() {
        Test.startTest();
        new vertic_FlowProc().process(new Map<String,Object>{
                'flow' => 'websiteIntegration',
                'inputs' => new Map<String, Object>{
                    'contactLastName' => 'test'
                },
                'outputFields' => new List<String>()
        });
        Test.stopTest();
    }
}