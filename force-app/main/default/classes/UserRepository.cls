public class UserRepository implements IUserRepository {
    public Map<Id, User> getUsersById(Set<Id> userIds) {
        return new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
    }
}