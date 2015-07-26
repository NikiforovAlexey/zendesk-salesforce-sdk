// This class provides functionality to call the Zendesk Organizations API
public class ZendeskOrganizationsAPI extends ZendeskResourceBase {

	public class OrganizationsWrapper extends ZendeskPagingBase {
		public List<ZOrganization> organizations {get;set;}
	}

	public class OrganizationWrapper extends ZendeskSideLoadingBase {
		public ZOrganization organization {get;set;}
	}

	public ZendeskOrganizationsAPI(ZendeskAPI zapi) {
		super(zapi);
	}

	public OrganizationsWrapper getOrganizations() {
        return getOrganizations(zapi.createRequest('GET', '/organizations.json'));
    }

    public OrganizationsWrapper getOrganizations(Map<String, Object> queryParams) {
        return getOrganizations(zapi.createRequest('GET', '/organizations.json', queryParams));
    }

	public OrganizationsWrapper getOrganizationsByIds(Set<Long> orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }

        return getOrganizations(zapi.createRequest('GET', '/organizations/show_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)}));
    }

	public OrganizationsWrapper getOrganizationsByExternalIds(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

        return getOrganizations(zapi.createRequest('GET', '/organizations/show_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)}));
    }

	public OrganizationsWrapper getOrganizations(String autoCompleteName) {
		if (String.isBlank(autoCompleteName) || autoCompleteName.length() < 2) { throw new ZendeskException('autoCompleteName parameter must at least 2 characters'); }

        return getOrganizations(zapi.createRequest('GET', '/organizations/autocomplete.json', new Map<String, Object>{'name'=>autoCompleteName}));
    }

	public OrganizationsWrapper searchOrganizations(String externalId) {
		if (String.isBlank(externalId)) { throw new ZendeskException('externalId parameter must not be null or empty'); }

        return getOrganizations(zapi.createRequest('GET', '/organizations/search.json', new Map<String, Object>{'external_id'=>externalId}));
    }

	public OrganizationsWrapper getUserOrganizations(Long userId) {
		if (userId == null) { throw new ZendeskException('userId parameter must not be null'); }

        return getOrganizations(zapi.createRequest('GET', '/users/'+userId+'/organizations.json'));
    }

	// Helper method for GET Organization's
	private OrganizationsWrapper getOrganizations(HttpRequest req) {
        return (OrganizationsWrapper)JSON.deserialize(zapi.sendRequest(req), OrganizationsWrapper.class);
    }

	public OrganizationWrapper getOrganization(Long orgId) {
		return getOrganization(orgId, null);
    }

	public OrganizationWrapper getOrganization(Long orgId, Map<String, Object> queryParams) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/'+orgId+'.json', queryParams);
        return (OrganizationWrapper)JSON.deserialize(zapi.sendRequest(req), OrganizationWrapper.class);
    }

	public Map<String, Object> getOrganizationRelatedInfo(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

        HttpRequest req = zapi.createRequest('GET', '/organizations/'+orgId+'/related.json');
		return (Map<String, Object>)JSON.deserializeUntyped(zapi.sendRequest(req));
	}

	public Long createOrganization(ZOrganization zorg) {
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('POST', '/organizations.json');
        req.setBody('{ "organization": ' + stripJsonNulls(JSON.serialize(zorg)) + '}');
        OrganizationWrapper resultWrapper = (OrganizationWrapper)JSON.deserialize(zapi.sendRequest(req), OrganizationWrapper.class);
		return ((resultWrapper==null || resultWrapper.organization==null) ? null : resultWrapper.organization.id);
    }

	public ZendeskTypes.ZJobStatus createOrganizations(List<ZOrganization> zorgs) {
        if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter must not be null or empty'); }

        HttpRequest req = zapi.createRequest('POST', '/organizations/create_many.json');
        req.setBody('{ "organizations": ' + stripJsonNulls(JSON.serialize(zorgs)) + '}');
        return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
    }

    public void updateOrganization(Long orgId, ZOrganization zorg) {
        if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organizations/'+orgId+'.json');
		req.setBody('{ "organization": ' + stripJsonNulls(JSON.serialize(zorg)) + '}');
		zapi.sendRequest(req);
    }

	public ZendeskTypes.ZJobStatus updateOrganizations(List<ZOrganization> zorgs) {
		if (zorgs == null || zorgs.isEmpty()) { throw new ZendeskException('zorgs parameter must not be null or empty'); }
		for (ZOrganization zorg : zorgs) {
			if (zorg.id == null && String.isEmpty(zorg.external_id)) { throw new ZendeskException('Each org must have either an id or external_id populated'); }
		}

		HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json');
		req.setBody('{ "organizations": ' + stripJsonNulls(JSON.serialize(zorgs)) + '}');
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateOrganizations(Set<Long> orgIds, ZOrganization zorg) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }
        if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

        HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
		req.setBody('{ "organization": ' + stripJsonNulls(JSON.serialize(zorg)) + '}');
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus updateOrganizations(Set<String> externalIds, ZOrganization zorg) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }
		if (zorg == null) { throw new ZendeskException('zorg parameter must not be null'); }

		HttpRequest req = zapi.createRequest('PUT', '/organizations/update_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
		req.setBody('{ "organization": ' + stripJsonNulls(JSON.serialize(zorg)) + '}');
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public void deleteOrganization(Long orgId) {
		if (orgId == null) { throw new ZendeskException('orgId parameter must not be null'); }

		zapi.sendRequest(zapi.createRequest('DELETE', '/organizations/'+orgId+'.json'));
	}

	public ZendeskTypes.ZJobStatus deleteOrganizations(Set<Long> orgIds) {
		if (orgIds == null || orgIds.isEmpty()) { throw new ZendeskException('orgIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'ids'=>toCSV(orgIds)});
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

	public ZendeskTypes.ZJobStatus deleteOrganizations(Set<String> externalIds) {
		if (externalIds == null || externalIds.isEmpty()) { throw new ZendeskException('externalIds parameter must not be null or empty'); }

		HttpRequest req = zapi.createRequest('DELETE', '/organizations/destroy_many.json', new Map<String, Object>{'external_ids'=>toCSV(externalIds)});
		return (ZendeskTypes.ZJobStatus)JSON.deserialize(zapi.sendRequest(req), ZendeskTypes.ZJobStatus.class);
	}

}