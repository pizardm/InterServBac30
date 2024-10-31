public class MilestoneSemaforoController {
    @AuraEnabled
    public static CaseMilestone getMilestoneInfo(Id caseId) {
        CaseMilestone milestone = [
            SELECT Id, MilestoneType.Name, TargetDate
            FROM CaseMilestone
            WHERE CaseId = :caseId
            AND IsCompleted = false
            ORDER BY TargetDate ASC
            LIMIT 1
        ];
        return milestone;
    }
}