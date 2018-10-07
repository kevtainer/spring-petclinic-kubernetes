from locust import HttpLocust, TaskSet, task
from random import choice
from random import randint

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        print('Starting')

    @task
    def load(self):
        self.client.get('/')
        self.client.get('/api/vet/vets').json()
        owners = self.client.get('/api/customer/owners').json()

        for owner in owners:
            ownerid = owner['id']
            #print('Owner {}'.format(ownerid))

            self.client.get('/api/owner/owners/{}'.format(ownerid))

            print('Owner {}'.format(owner))

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 1000
    max_wait = 5000