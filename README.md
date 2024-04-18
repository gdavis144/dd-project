## SongBird App

## Steps for running:
1. There should be a .env file under /nextjs-dashboard. If not, create one. In the .env file, make sure that the env variables are set correctly. You should have:

HOST="*your host name*"
USER="*your user name*"
PASSWORD="*your password*"
DB_NAME="music"
CURRENT_USER="user1"
AUTH_SECRET="/sMzZmR3Q30tXFSY8poq3l1hi6piQjEwSDcH1cfNqDc="
AUTH_URL=http://localhost:3000/api/auth

Please set HOST, USER, and PASSWORD to your connection details.
2. Start your MySql Server, and run the dump file provided in nextjs-dashboard/scripts/dump.sql
3. Open a terminal, and navigate to the /nextjs-dashboard folder.
4. Run `npm run dev`. You may need to install npm, instructions are at https://docs.npmjs.com/downloading-and-installing-node-js-and-npm
6. Navigate to localhost:3000 in a browser - previous command will not show as complete until this is done.
7. Log in with the below credentials:
USER: user1
PASSWORD: password1
8. Horray! You've logged in. Because of the dev environment, each page takes time to load, please be patient with the pages.

# Troubleshooting
1. You may also need to install nextjs or react, installation instructions are below
https://next-auth.js.org/getting-started/example
https://react.dev/