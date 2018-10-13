from locust import HttpLocust, TaskSet, task
from faker import Faker
from random import choice
from random import randint
import os

fake = Faker()

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
            #print('Owner {}'.format(owner))

        if os.environ['INJECT'] == "1":
            #if randint(1, 100) <= 25:
            owner = {
                "address":fake.street_address(),
                "city":fake.city(),
                "firstName":fake.first_name(),
                "lastName":fake.last_name(),
                "telephone": randint(1000000000,9999999999)
            }
            res = self.client.post('/api/customer/owners', json=owner)
            print('New Owner {}'.format(res))


class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 1000
    max_wait = 5000