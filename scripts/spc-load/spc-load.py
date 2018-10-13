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
            self.client.get('/api/owner/owners/{}'.format(ownerid))

        if os.environ['INJECT'] == "1":
            if randint(1, 100) <= 25:
                owner = {
                    "address":fake.street_address(),
                    "city":fake.city(),
                    "firstName":fake.first_name(),
                    "lastName":fake.last_name(),
                    "telephone": randint(1000000000,9999999999)
                }
                owner = self.client.post('/api/customer/owners', json=owner).json()
                ownerid = owner['id']

                for i in range(randint(1,3)):
                    pet = {
                        "birthDate": fake.iso8601(),
                        "id": 0,
                        "name": fake.first_name(),
                        "typeId": randint(1,6)
                    }
                    pet = self.client.post('/api/customer/owners/{}/pets'.format(ownerid), json=pet).json()
                    petid = pet['id']

                    for i in range(randint(0,4)):
                        visit = {
                            "date": fake.date(),
                            "description": fake.text()
                        }
                        self.client.post('/api/visit/owners/{}/pets/{}/visits'.format(ownerid,petid), json=visit)


class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 1000
    max_wait = 5000