# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :addAnswer,                mutation: Mutations::AddAnswer
    field :addIssueComment,          mutation: Mutations::AddIssueComment
    field :addNotice,                mutation: Mutations::AddNotice
    field :addPenalty,               mutation: Mutations::AddPenalty
    field :addProblemSupplement,     mutation: Mutations::AddProblemSupplement
    field :applyCategory,            mutation: Mutations::ApplyCategory
    field :applyProblem,             mutation: Mutations::ApplyProblem
    field :applyProblemEnvironment,  mutation: Mutations::ApplyProblemEnvironment
    field :applyScore,               mutation: Mutations::ApplyScore
    field :applyTeam,                mutation: Mutations::ApplyTeam
    field :confirmingAnswer,         mutation: Mutations::ConfirmingAnswer
    field :deleteAttachment,         mutation: Mutations::DeleteAttachment
    field :deleteCategory,           mutation: Mutations::DeleteCategory
    field :deleteIssueComment,       mutation: Mutations::DeleteIssueComment
    field :deleteNotice,             mutation: Mutations::DeleteNotice
    field :deleteProblem,            mutation: Mutations::DeleteProblem
    field :deleteProblemEnvironment, mutation: Mutations::DeleteProblemEnvironment
    field :deleteProblemSupplement,  mutation: Mutations::DeleteProblemSupplement
    field :deleteSession,            mutation: Mutations::DeleteSession
    field :deleteTeam,               mutation: Mutations::DeleteTeam
    field :pinNotice,                mutation: Mutations::PinNotice
    field :regradeAnswers,           mutation: Mutations::RegradeAnswers
    field :startIssue,               mutation: Mutations::StartIssue
    field :transitionIssueState,     mutation: Mutations::TransitionIssueState
    field :updateConfig,             mutation: Mutations::UpdateConfig

    class << self
      def get_fields_query(name, with: nil)
        self.fields
          .fetch(name)
          .mutation
          .to_fields_query(with: with)
      end
    end
  end
end
