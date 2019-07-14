from locust import HttpLocust, TaskSet, task
from glob import glob
import os
queries = {}

for filepath in glob('queries/*.gql'):
    with open(filepath) as file:
        key = os.path.splitext(os.path.basename(filepath))[0]
        queries[key] = file.read()


class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        self.login()

    def on_stop(self):
        """ on_stop is called when the TaskSet is stopping """
        self.logout()

    def login(self):
        self.client.headers = {
            'Content-Type': 'application/json'
            }
        self.client.post("/api/sessions", json = { "name": "staff", "password": "staff"} )

    def logout(self):
        self.client.delete("/api/sessions")

    def post_query(self, query_string):
        self.client.headers = { 'Content-Type': 'application/json' }
        self.client.post("/api/graphql", json={ 'query': query_string }, timeout=1000.0*10)

    @task(1)
    def problems_heavy(self):
        self.post_query(queries['problems_heavy'])


class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 2000
    max_wait = 7000
