// This class provides functionality to call the Zendesk Group Memberships API
global class ZendeskGroupMembershipsAPI extends ZendeskResourceBase {

    global class GroupMembershipWrapper extends ZendeskSideLoadingBase {
        global ZGroupMembership group_membership {get;set;}
        global GroupMembershipWrapper(ZGroupMembership groupMembership) { this.group_membership = group_membership; }
    }

    global class GroupMembershipsWrapper extends ZendeskPagingBase {
        global List<ZGroupMembership> group_memberships {get;set;}
        global GroupMembershipsWrapper(List<ZGroupMembership> groupMemberships) { this.group_memberships = groupMemberships; }
    }

    global ZendeskGroupMembershipsAPI(ZendeskConnection zconn) {
        super(zconn);
    }

    // GET /api/v2/group_memberships/{id}.json
    global GroupMembershipWrapper getMembership(Long membershipId) {
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/group_memberships/'+membershipId+'.json');
        return (GroupMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupMembershipWrapper.class);
    }

    // GET /api/v2/users/{user_id}/group_memberships/{id}.json
    global GroupMembershipWrapper getMembership(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('GET', '/users/'+userId+'/group_memberships/'+membershipId+'.json');
        return (GroupMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupMembershipWrapper.class);
    }

    // GET /api/v2/group_memberships.json
    global GroupMembershipsWrapper getGroupsMemberships() {
        return getGroupMemberships(null);
    }
    global GroupMembershipsWrapper getGroupMemberships(Map<String, Object> queryParams) {
        return getGroupMembershipsInternal(zconn.createRequest('GET', '/group_memberships.json', queryParams));
    }

    // GET /api/v2/users/{user_id}/group_memberships.json
    global GroupMembershipsWrapper getMembershipsByUser(Long userId) {
        return getMembershipsByUser(userId, null);
    }
    global GroupMembershipsWrapper getMembershipsByUser(Long userId, Map<String, Object> queryParams) {
        return getGroupMembershipsInternal(zconn.createRequest('GET', '/users/'+userId+'/group_memberships.json', queryParams));
    }

    // GET /api/v2/groups/{group_id}/memberships.json
    global GroupMembershipsWrapper getMembershipsByGroup(Long groupId) {
        return getMembershipsByGroup(groupId, null);
    }
    global GroupMembershipsWrapper getMembershipsByGroup(Long groupId, Map<String, Object> queryParams) {
        return getGroupMembershipsInternal(zconn.createRequest('GET', '/groups/'+groupId+'/memberships.json', queryParams));
    }

    // GET /api/v2/group_memberships/assignable.json
    global GroupMembershipsWrapper getAssignableMemberships() {
        return getAssignableMemberships(null);
    }
    global GroupMembershipsWrapper getAssignableMemberships(Map<String, Object> queryParams) {
        return getGroupMembershipsInternal(zconn.createRequest('GET', '/group_memberships/assignable.json', queryParams));
    }

    // GET /api/v2/groups/{group_id}/memberships/assignable.json
    global GroupMembershipsWrapper getAssignableMembershipsByGroup(Long groupId) {
        return getAssignableMembershipsByGroup(groupId, null);
    }
    global GroupMembershipsWrapper getAssignableMembershipsByGroup(Long groupId, Map<String, Object> queryParams) {
        return getGroupMembershipsInternal(zconn.createRequest('GET', '/groups/'+groupId+'/memberships/assignable.json', queryParams));
    }

    // Private helper method to retrieve multiple group memberships
    private GroupMembershipsWrapper getGroupMembershipsInternal(HttpRequest req) {
        return (GroupMembershipsWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupMembershipsWrapper.class);
    }

    // POST /api/v2/users/{user_id}/group_memberships.json
    global Long createGroupMembership(Long userId, Long groupId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (groupId == null) { throw new ZendeskException('groupId parameter cannot be null'); }

        ZGroupMembership gm = new ZGroupMembership();
        gm.user_id = userId;
        gm.group_id = groupId;

        HttpRequest req = zconn.createRequest('POST', '/users/'+userId+'/group_memberships.json');
        req.setBody(stripJsonNulls(unreplaceReservedWords(JSON.serialize(new GroupMembershipWrapper(gm)))));
        GroupMembershipWrapper resultWrapper = (GroupMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupMembershipWrapper.class);
        return ((resultWrapper==null || resultWrapper.group_membership == null) ? null : resultWrapper.group_membership.id);
    }

    global Long createGroupMembership(ZGroupMembership groupMembership) {
        if (groupMembership == null) { throw new ZendeskException('groupMembership parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('POST', '/group_memberships.json');
        req.setBody(stripJsonNulls(unreplaceReservedWords(JSON.serialize(new GroupMembershipWrapper(groupMembership)))));
        GroupMembershipWrapper resultWrapper = (GroupMembershipWrapper)JSON.deserialize(replaceReservedWords(zconn.sendRequest(req)), GroupMembershipWrapper.class);
        return ((resultWrapper==null || resultWrapper.group_membership == null) ? null : resultWrapper.group_membership.id);
    }

    // PUT /api/v2/users/{user_id}/group_memberships/{id}/make_default.json
    global void makeDefault(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        HttpRequest req = zconn.createRequest('PUT', '/users/'+userId+'/group_memberships/'+membershipId+'/make_default.json', '{}');
        zconn.sendRequest(req);
    }

    // DELETE /api/v2/users/{user_id}/group_memberships/{id}.json
    global void deleteGroupMembership(Long userId, Long membershipId) {
        if (userId == null) { throw new ZendeskException('userId parameter cannot be null'); }
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/users/'+userId+'/group_memberships/'+membershipId+'.json'));
    }

    // DELETE /api/v2/group_memberships/{id}.json
    global void deleteGroupMembership(Long membershipId) {
        if (membershipId == null) { throw new ZendeskException('membershipId parameter cannot be null'); }

        zconn.sendRequest(zconn.createRequest('DELETE', '/group_memberships/'+membershipId+'.json'));
    }

    // replace reserved keywords in the JSON string and map them to field names prefixed with "x_"
    // Use when calling deserialize()
    private String replaceReservedWords(String str) {
        str = str.replaceAll('"default"\\s*:', '"x_default":');
        return str;
    }

    // un-replace reserved keywords in the JSON string
    // Use when calling serialize()
    private String unreplaceReservedWords(String str) {
        str = str.replaceAll('"x_default"\\s*:', '"default":');
        return str;
    }
}