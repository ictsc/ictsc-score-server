Role.seed do |r|
  r.id = 1
  r.name = "Admin"
  r.rank = 1
end

Role.seed do |r|
  r.id = 2
  r.name = "Writer"
  r.rank = 10
end

Role.seed do |r|
  r.id = 3
  r.name = "Participant"
  r.rank = 20
end

Role.seed do |r|
  r.id = 4
  r.name = "Viewer"
  r.rank = 20
end
