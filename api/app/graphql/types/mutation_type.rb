# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :addAnswer,                mutation: Mutations::AddAnswer
    field :addIssueComment,          mutation: Mutations::AddIssueComment
    field :addNotice,                mutation: Mutations::AddNotice
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
    field :pinNotice,                mutation: Mutations::PinNotice
    field :regradeAnswers,           mutation: Mutations::RegradeAnswers
    field :startIssue,               mutation: Mutations::StartIssue
    field :transitionIssueState,     mutation: Mutations::TransitionIssueState
    field :updateConfig,             mutation: Mutations::UpdateConfig
  end
end
