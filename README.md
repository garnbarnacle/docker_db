# Local Postgres for the research-db project

This spins up a single PostgreSQL database in Docker on your own Windows machine,
with data that persists across restarts, and gets it reachable from DBeaver.

## 1. Install Docker Desktop (skip if you already have it)

1. Download Docker Desktop for Windows from docker.com and run the installer.
2. When prompted, let it enable the **WSL2 backend** (the default on modern
   Windows 10/11) — you don't need to know WSL2 beyond that checkbox.
3. Restart your machine if the installer asks you to.
4. Launch Docker Desktop and wait for it to say "Docker Desktop is running"
   (whale icon steady in the system tray). Leave it running in the background
   whenever you want the database available.

## 2. Get this folder onto your machine

Save this whole folder (`docker-compose.yml`, `.env.example`, `.gitignore`,
and this README) into a location such as:

    C:\Users\<you>\research-db\

## 3. Create your real .env file

The actual username/password live in a `.env` file that is deliberately
**not** shared or committed to GitHub — `.env.example` just shows the shape
of it. Make your own copy:

    copy .env.example .env

Then open `.env` in a text editor and set real values, e.g.:

    POSTGRES_USER=garnett
    POSTGRES_PASSWORD=pick-something-only-you-know
    POSTGRES_DB=research
    POSTGRES_PORT=5432

`docker-compose.yml` reads these values automatically — you never put a real
password directly in the compose file itself.

## 4. Start the database

Open a terminal (PowerShell is fine) in that folder and run:

    docker compose up -d

The first run downloads the official `postgres:16` image (a few hundred MB),
then starts the container in the background. Confirm it's up with:

    docker ps

You should see a container named `research_postgres` with status `Up`.

## 5. Connect with DBeaver

In DBeaver: **Database → New Database Connection → PostgreSQL**, then enter
the host/port/database/username/password you put in your `.env` file — for
the example values above that's:

| Field    | Value           |
|----------|-----------------|
| Host     | localhost       |
| Port     | 5432            |
| Database | research        |
| Username | garnett         |
| Password | (whatever you set in .env) |

Click **Test Connection** (DBeaver will offer to download the PostgreSQL
driver the first time — let it), then **Finish**. You should now see the
`research` database and be able to browse/query it exactly like you would
in Access, just with real SQL.

## Day-to-day use

- Stop the database without deleting data: `docker compose stop`
- Start it again later: `docker compose start`
- Fully remove the container (data is safe in the named volume `pgdata`):
  `docker compose down`
- Bring it back (recreates the container, same data): `docker compose up -d`
- **Destroy the data too** (only if you really mean it): `docker compose down -v`

## Putting this in GitHub

This folder is now safe to commit as-is: `docker-compose.yml`,
`.env.example`, `.gitignore`, and this README all belong in the repo. Your
real `.env` is excluded by `.gitignore`, so it never gets pushed — anyone
(including future you, on a different machine) who clones the repo just
copies `.env.example` to `.env` and fills in their own values, per step 3
above.

## A couple of notes

- If you ever expose this port beyond `localhost` (e.g. a shared lab
  machine), pick a stronger password in `.env` than a simple dev one.
- This setup is meant to grow: once Postgres feels comfortable, the next
  step in the plan is adding NocoDB (data-entry forms) and Metabase
  (reporting) as two more `services:` entries in this same
  `docker-compose.yml`, all reading from this same `research` database —
  their credentials would follow the same `.env` pattern.
