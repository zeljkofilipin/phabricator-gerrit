def gerrit_repositories(gerritbot_comments)
  gerritbot_comments.map do |element|
    element['comments'][0]['content']['raw'].split('[')[1].split('@')[0]
  end.uniq.compact
end

def gerritbot_comments(task_comments)
  return [] unless task_comments['result']

  task_comments['result']['data'].select do |element|
    gerritbot = 'PHID-USER-idceizaw6elwiwm5xshb'
    element['authorPHID'] == gerritbot && !element['comments'].empty?
  end
end

def task_comments(task_json)
  require 'json'
  JSON.parse(task_json)
end

def task_json(phabricator_task)
  api_token = ARGV[0]
  `curl \
  -s \
  https://phabricator.wikimedia.org/api/transaction.search \
  -d api.token=#{api_token} \
  -d objectIdentifier=#{phabricator_task}`
end

def tasks_repos(tasks)
  tasks.map do |task|
    { task =>
      gerrit_repositories(
        gerritbot_comments(task_comments(task_json(task)))
      ) }
  end
end

def repos_tasks(incidents, incidents_phabricator)
  incidents_phabricator_repository = {}
  incidents.each do |incident|
    incidents_phabricator_repository[incident] =
      tasks_repos(incidents_phabricator[incident])
  end
  incidents_phabricator_repository
end
