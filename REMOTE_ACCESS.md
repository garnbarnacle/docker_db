# Making research-db reachable from both computers

This moves the Postgres stack off your laptop and onto a small always-on
server, and uses Tailscale (a free private-network tool) so both of your
computers can reach it by a stable address — without opening it up to the
public internet. Read this alongside the main `README.md`; the day-to-day
Docker commands there don't change, they just get run on the server instead
of your laptop.

## 1. Create the VPS

Any mainstream provider works (DigitalOcean, Linode, Hetzner, etc.). Pick:

- **Image:** Ubuntu 24.04 LTS
- **Size:** the cheapest tier (1 vCPU / 1 GB RAM) is plenty for Postgres
  alone; if you plan to add NocoDB and Metabase to the same stack later,
  go with a 2 GB RAM tier instead so all three run comfortably.
- **Region:** wherever is closest to you.

The provider will give you the server's public IP address and either a root
password or an SSH key — note how you'll SSH in, e.g.:

    ssh root@<the-vps-public-ip>

## 2. Get the project onto the server

If you've pushed `research-db` to GitHub already, this is the easiest path:

    git clone <your-repo-url>
    cd research-db
    cp .env.example .env

Then edit `.env` on the server with a text editor (`nano .env`) and set real
values — this `.env` is separate from the one on your laptop and, per
`.gitignore`, never gets pushed anywhere.

(No GitHub repo yet? `scp` the whole folder up instead:
`scp -r research-db root@<vps-ip>:~/`)

## 3. Run the bootstrap script

    chmod +x server_setup.sh
    ./server_setup.sh

This installs Docker and Tailscale, and locks the firewall down so port 5432
is reachable only over the private Tailscale network (plus SSH, so you can
always still administer the box). Partway through, Tailscale will print a
URL — open it in any browser and sign in to authenticate this server to your
Tailscale account (create a free account first at tailscale.com if you don't
have one).

At the end, the script prints this server's Tailscale address, something
like `100.x.x.x`. Write that down — that's what both computers will connect
to.

## 4. Start the database

Same as on your laptop:

    newgrp docker        # only needed once, for the group change to apply
    docker compose up -d

Because `restart: unless-stopped` is already set in `docker-compose.yml`,
the container comes back up automatically if the VPS ever reboots — you
don't have to remember to restart it.

## 5. Connect both computers via Tailscale

On each computer:

1. Install Tailscale from tailscale.com/download.
2. Sign in with the **same Tailscale account** you used on the server.

That's it — no router configuration, no port forwarding. Both machines are
now on the same private network as the server.

## 6. Point DBeaver at the server instead of localhost

On each computer, edit your existing DBeaver connection (or make a new one)
and change only the **Host** field, from `localhost` to the VPS's Tailscale
address from step 3, e.g. `100.x.x.x`. Port, database, username, and
password stay exactly what's in the server's `.env`.

Both computers now read and write the same live database — no more "which
laptop has the current copy" problem.

## Notes

- Treat the server's `.env` as the source of truth for credentials; there's
  no need to keep your laptop's local `.env` in sync with it once the
  server is running things.
- If you later add NocoDB or Metabase as more `services:` in
  `docker-compose.yml`, they come along for free here too — same server,
  same Tailscale network, just a different port per service.
- Tailscale's free tier comfortably covers "me, on two of my own machines,
  plus one server" — you won't hit any limits at this scale.
