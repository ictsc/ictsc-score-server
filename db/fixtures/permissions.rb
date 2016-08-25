ROLE_ID = {
  admin: 2,
  writer: 3,
  participant: 4,
  viewer: 5,
  nologin: 1,
}

PERMIT_ALL = ""
FORBID_ALL = "0" # Also written in db/models.rb

def def_perm(resource, role, methods, action: "", query: nil, parameters: nil, join: "")
  methods = [methods] if not methods.is_a? Array

  methods.each do |method|
    Permission.seed(:resource, :role_id, :action, :method) do |p|
      p.resource   = resource.to_s.downcase.pluralize
      p.action     = action.to_s
      p.method     = method.to_s.upcase
      p.query      = query
      p.parameters = parameters
      p.join       = join
      p.role_id    = ROLE_ID[role]
    end
  end
end

def permit(resource, role, methods, **option)
  def_perm(resource, role, methods, query: PERMIT_ALL, **option)
end

def forbid(resource, role, methods, **option)
  def_perm(resource, role, methods, query: FORBID_ALL, **option)
end

%i(admin writer participant viewer).each do |role|
  permit(Member, role, %i(GET), action: :members_me)
end

%i(writer participant viewer).each do |role|
  permit(Team, role, %i(GET))
  def_perm(Comment, role, %i(GET),
           action: :problems_comments,
           query: "commentable_type = :commentable_type",
           parameters: "{ commentable_type: 'Problem' }")
end


# Nologin

def_perm(Role, :nologin, %i(GET),
  query: "id = :participant_role_id",
  parameters: "{ participant_role_id: #{ROLE_ID[:participant]}}")
permit(Member, :nologin, %i(POST))
permit(Team, :nologin, %i(GET))


# Admin

%i(Role Member Team Score Problem Issue Answer Notice Attachment).each do |resource|
  permit(resource, :admin, %i(GET POST PUT PATCH DELETE))
end

%i(Problem Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  permit(resource, :admin, %i(GET), action: action)
  def_perm(Comment,  :admin, %i(GET POST PUT PATCH DELETE),
           action: action,
           query: "commentable_type = :commentable_type",
           parameters: "{ commentable_type: '#{resource.to_s}' }")
end


# Writer

permit(Attachment, :writer, %i(GET POST PUT PATCH DELETE))
permit(Team,       :writer, %i(POST PUT PATCH DELETE))
permit(Problem,    :writer, %i(GET POST))
permit(Issue,      :writer, %i(GET POST PUT PATCH DELETE))
permit(Answer,     :writer, %i(GET POST PUT PATCH DELETE))
permit(Score,      :writer, %i(GET POST))

permit(Issue,   :writer, %i(GET), action: :issues_comments)
def_perm(Comment, :writer, %i(GET POST PUT PATCH DELETE),
         action: :issues_comments,
         query: "commentable_type = :commentable_type",
         parameters: "{ commentable_type: 'Issue' }")

permit(Answer,  :writer, %i(GET), action: :answers_comments)
def_perm(Comment, :writer, %i(GET),
         action: :answers_comments,
         query: "commentable_type = :commentable_type",
         parameters: "{ commentable_type: 'Answer' }")

forbid(Comment, :writer, %i(POST PUT PATCH DELETE), action: :answers_comments)

def_perm(Member, :writer, %i(GET POST PUT PATCH DELETE),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

def_perm(Role,   :writer, %i(GET),
  query: "rank >= :rank",
  parameters: "{ rank: role.rank }")

def_perm(Member, :writer, %i(GET POST PUT PATCH DELETE),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

def_perm(Problem, :writer, %i(PUT PATCH DELETE),
  query: "creator_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Problem, :writer, %i(GET),
  action: :problems_comments,
  query: "creator_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Comment, :writer, %i(POST PUT PATCH DELETE),
  action: :problems_comments,
  query: "member_id = :id AND commentable_type = :commentable_type",
  parameters: "{ id: current_user.id, commentable_type: 'Problem' }")

def_perm(Score, :writer, %i(PUT PATCH DELETE),
  query: "marker_id = :id",
  parameters: "{ id: current_user.id }")

permit(Notice,  :writer, %i(GET POST))
def_perm(Notice, :writer, %i(PUT PATCH DELETE),
  query: "member_id = :id",
  parameters: "{ id: current_user.id }")

# Participant

permit(Member,     :participant, %i(GET))
forbid(Member,     :participant, %i(POST DELETE))
permit(Notice,     :participant, %i(GET))
forbid(Notice,     :participant, %i(POST DELETE))
forbid(Team,       :participant, %i(POST PUT PATCH DELETE))
forbid(Problem,    :participant, %i(POST PUT PATCH DELETE))
forbid(Attachment, :participant, %i(POST PUT PATCH DELETE))
permit(Issue,      :participant, %i(POST))
forbid(Issue,      :participant, %i(DELETE))
permit(Answer,     :participant, %i(POST))
forbid(Answer,     :participant, %i(DELETE))
forbid(Score,      :participant, %i(GET POST PUT PATCH DELETE))
forbid(Comment,    :participant, %i(POST PUT PATCH DELETE), action: "problems_comments")
forbid(Comment,    :participant, %i(DELETE), action: "issues_comments")
forbid(Answer,     :participant, %i(GET),    action: "answers_comments")
forbid(Comment,    :participant, %i(DELETE), action: "answers_comments")

def_perm(Attachment, :participant, %i(GET),
  query: "member_id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Member, :participant, %i(PUT PATCH),
  query: "id = :id",
  parameters: "{ id: current_user.id }")

def_perm(Problem, :participant, %i(GET),
  query: "opened_at <= :now",
  parameters: "{ now: DateTime.now }")

def_perm(Problem, :participant, %i(GET),
  action: "problems_comments",
  query: "opened_at <= :now",
  parameters: "{ now: DateTime.now }")

%i(Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"

  def_perm(resource, :participant, %i(GET PUT PATCH),
    query: "team_id = :team_id",
    parameters: "{ team_id: current_user.team_id }")

  def_perm(resource, :participant, %i(GET PUT PATCH),
    action: action,
    query: "team_id = :team_id",
    parameters: "{ team_id: current_user.team_id }")

  def_perm(Comment, :participant, %i(GET POST PUT PATCH),
    action: action,
    query: "members.team_id = :team_id AND commentable_type = :commentable_type",
    parameters: "{ team_id: current_user.team_id, commentable_type: '#{resource.to_s}' }",
    join: "member")
end

# Viewer

def_perm(Member, :viewer, %i(GET),
  query: "roles.rank >= :rank",
  parameters: "{ rank: role.rank }",
  join: "role")

%i(Problem Score Issue Answer Notice Attachment).each do |resource|
  permit(resource, :viewer, %i(GET))
end

%i(Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  permit(resource, :viewer, %i(GET), action: action)
  permit(Comment,  :viewer, %i(GET),
         action: action,
         query: "commentable_type = :commentable_type",
         parameters: "{ commentable_type: '#{resource.to_s}' }")
end

%i(Member Team Score Problem Issue Answer Notice Attachment).each do |resource|
  forbid(resource, :viewer, %i(POST PUT PATCH DELETE))
end

%i(Problem Issue Answer).each do |resource|
  action = "#{resource.to_s.downcase.pluralize}_comments"
  forbid(resource, :viewer, %i(GET), action: action)
  forbid(Comment,  :viewer, %i(POST PUT PATCH DELETE),
         action: action,
         query: "commentable_type = :commentable_type",
         parameters: "{ commentable_type: '#{resource.to_s}' }")
end
