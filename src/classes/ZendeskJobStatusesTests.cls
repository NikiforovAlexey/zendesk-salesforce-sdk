// This class provides test coverage for the ZendeskJobStatuses class
@isTest
private class ZendeskJobStatusesTests {

    public class MockStatusResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{"job_status": { "id": "31a2e47012e20", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e4701.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name:  is too short" } ] } }');
            return res;
        }
    }

    public class MockStatusesResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            res.setBody('{ "job_statuses": [{ "id": "31a2e47012e", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name:  is too short" } ] } ,{ "id": "31a2e47012e201", "url": "https://test.zendesk.com/api/v2/job_statuses/31a2e47012e201.json", "total": 2, "progress": 2, "status": "completed", "message": "Completed", "results": [ { "status": "Failed Creating User ", "errors": "Name: is too short" } ] }  ] }');
            return res;
        }
    }

    static testMethod void testGetStatus() {
        Test.setMock(HttpCalloutMock.class, new MockStatusResponse());

        Test.startTest();
        ZendeskJobStatuses zjobs = new ZendeskJobStatuses(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskJobStatuses.JobStatus job = zjobs.getJobStatus('abc123');
        Test.stopTest();

        System.assertNotEquals(null, job);
        System.assertEquals('31a2e47012e20', job.id);
    }

    static testMethod void testGetStatuses() {
        Test.setMock(HttpCalloutMock.class, new MockStatusesResponse());

        Test.startTest();
        ZendeskJobStatuses zjobs = new ZendeskJobStatuses(new ZendeskAPI('s', 'u', 'p', ZendeskAPI.AuthType.Password));
        ZendeskJobStatuses.JobStatus[] jobs = zjobs.getJobStatuses(new String[] {'abc123', 'abc345'});
        Test.stopTest();

        System.assertNotEquals(null, jobs);
        System.assertEquals(2, jobs.size());
    }

}