from locust import HttpLocust, TaskSet, task
from faker import Faker
from random import choice
from random import randint
import os
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
fake = Faker()

class UserBehavior(TaskSet):
    def on_start(self):
        """ on_start is called when a Locust start before any task is scheduled """
        print('Starting')

    @task
    def load(self):
        self.client.get('/', verify=False)
        self.client.get('/api/vet/vets', verify=False).json()
        owners = self.client.get('/api/customer/owners', verify=False).json()

        for i in range(20):
            self.client.get('/api/owner/owners/{}'.format(randint(1, len(owners))), verify=False)

        if os.environ['INJECT'] == "1":
            if randint(1, 100) <= 25:
                owner = {
                    "address":fake.street_address(),
                    "city":fake.city(),
                    "firstName":fake.first_name(),
                    "lastName":fake.last_name(),
                    "email":fake.email(),
                    "telephone": randint(1000000000,9999999999)
                }
                owner = self.client.post('/api/customer/owners', json=owner, verify=False).json()
                ownerid = owner['id']

                for i in range(randint(1,3)):
                    pet = {
                        "birthDate": fake.iso8601(),
                        "id": 0,
                        "name": fake.first_name(),
                        "typeId": randint(1,6)
                    }
                    pet = self.client.post('/api/customer/owners/{}/pets'.format(ownerid), json=pet, verify=False).json()
                    petid = pet['id']

                    for i in range(randint(0,4)):
                        visit = {
                            "date": fake.date(),
                            "description": fake.text()
                        }
                        self.client.post('/api/visit/owners/{}/pets/{}/visits'.format(ownerid,petid), json=visit, verify=False)


class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 1000
    max_wait = 5000
