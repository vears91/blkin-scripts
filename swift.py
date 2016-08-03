import swiftclient
user = 'test:tester'
key = 'testing'

conn = swiftclient.Connection(
        user=user,
        key=key,
        authurl='http://127.0.0.1:8000/auth',
)

container_name = 'contain'
conn.put_container(container_name)

with open('/home/vh4x/blkin-scripts/hello.txt', 'r') as hello_file:
        conn.put_object(container_name, 'hello.txt',
                                        contents= hello_file.read(),
                                        content_type='text/plain')

for container in conn.get_account()[1]:
        print(container['name'])