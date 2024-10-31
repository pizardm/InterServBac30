public interface IUserRepository {
    Map<Id, User> getUsersById(Set<Id> userIds);
}