+++
title = "Using DigitalOcean as Dynamic DNS"
date = 2020-05-17T00:20:43-04:00
draft = false
tags = []
categories = []
+++

Recently, I've migrated my personal infrastructure to DigitalOcean. Since DigitalOcean offers DNS service at no added cost, I've moved my DNS from Cloudflare over to them as well. I simply trust a company I'm paying more than a company that I'm not. Previously, I had been using [this excellent Cloudflare dynamic DNS script](https://www.rohanjain.in/cloudflare-ddns/), and so used it as a basis to write my own for DigitalOcean.

## Prerequisites

* `curl`

    The shell script requires `curl` installed. Luckily, most Linux distributions have `curl` packaged officially.

* Domain name

    DigitalOcean's DNS is a fully-fledged DNS service but they're not a registrar. So, you'll have to [bring your own domain.](https://www.digitalocean.com/docs/networking/dns/quickstart/)

* A record

    Once you've added your domain to DigitalOcean, [add an A record](https://www.digitalocean.com/docs/networking/dns/how-to/manage-records/) for the subdomain you want to point to your dynamic IP. You'll want a reasonably low TTL - I use 300 seconds (5 minutes).

* DigitalOcean personal access token

    In order to change the A record programmatically, you'll need access to DigitalOcean's API. [Go to DigitalOcean's API page](https://cloud.digitalocean.com/account/api/) and click "Generate New Token". The token will need read _and_ write permissions in order to change the IP that the A record points to.

* Record ID

    This one's a bit tricky. The API to change DNS records requires that you identify which record you want to change via a Record ID. However, DigitalOcean's online management site does not show this ID anywhere. You'll have to query the API directly using `curl`:

    ```sh
    curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer {DigitalOcean personal access token}" "https://api.digitalocean.com/v2/domains/{Domain name: mysite.com}/records" | python -m json.tool
    ```

    Remember to fill out the token and domain parts. The pipe into Python is to get pretty-printing of the JSON and not strictly necessary. The response will list all your existing domain records, so you'll have to look for the `id` of the one corresponding to the subdomain you want to point to your dynamic IP.

## The Shell Script

Next, install the shell script on a computer behind the dynamic IP. I've put mine at `/usr/local/bin/digitalocean-ddns`. Again, don't forget to fill out the placeholders on the first few lines.

```sh
#/usr/bin/env sh
set -e

TOKEN={DigitalOcean personal access token}
RECORD_ID={DNS Record ID: 12345678}
DOMAIN_NAME="{Domain name: mysite.com}"
TMP_DIR="/tmp/digitalocean-ddns"
PREV_IP_FILE="$TMP_DIR/public-ip.txt"
API_RESP_FILE="$TMP_DIR/response.json"

# Ensure TMP_DIR exists
mkdir -p "$TMP_DIR"

# Get previous IP address
_PREV_IP=$(cat "$PREV_IP_FILE" &> /dev/null)

# Lookup current public IP
_IP=$(curl --silent https://api.ipify.org)

# If new/previous IPs match, no need for an update.
if [ "$_IP" = "$_PREV_IP" ]; then
    exit 0
fi

# Construct JSON payload for request
_UPDATE=$(cat <<EOF
{ "data": "$_IP" }
EOF
)

# Fire API request
curl "https://api.digitalocean.com/v2/domains/$DOMAIN_NAME/records/$RECORD_ID" \
     --silent \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer $TOKEN" \
     -d "$_UPDATE" > "$API_RESP_FILE" && \
     echo $_IP > "$PREV_IP_FILE"
```

Since it contains a sensitive API token, it's best practice to restrict reading/writing/executing this script to root (700 permissions).

## Systemd Files

Many Linux distributions these days come with `systemd`, and `systemd` timers have many advantages over good ol' `cron`. You'll need two files: a `service` file and a `timer` file. The service file runs the shell script. In `/etc/systemd/system/digitalocean-ddns.service`:
```systemd
[Unit]
Description=Update DNS entry for this host to current IP

[Service]
Type=oneshot
ExecStart=/bin/sh /usr/local/bin/digitalocean-ddns
```

The timer starts the service at regular intervals. In `/etc/systemd/system/digitalocean-ddns.timer`
```systemd
[Unit]
Description=Update DNS entry in digitalocean every 5 minutes

[Timer]
OnBootSec=1min
OnCalendar=*:0/5
Unit=digitalocean-ddns.service

[Install]
WantedBy=basic.target
```

Now, refresh systemd's configuration, then enable and start the timer. Enabling the timer makes it active after a fresh boot, and starting the timer make it active now.

```sh
$ sudo systemctl daemon-reload
$ sudo systemctl enable digitalocean-ddns.timer
$ sudo systemctl start digitalocean-ddns.timer
```

The last thing to do is to do a sanity check - you can use DigitalOcean's online management site to set your subdomain to point to a known IP, like `1.1.1.1` for Cloudflare. Then, directly run the shell script with `sudo`. On refresh, the management site should show your subdomain pointing to your dynamic IP. A second sanity check would be to let the timer run the script. Make sure you delete `/tmp/digitalocean-ddns/public-ip.txt` first, or else the API request won't be made!

## Debugging

Since this is a pretty simple shell script, it should be pretty easy to debug. Some pointers:

* Check the `API_RESP_FILE` file (by default `/tmp/digitalocean-ddns/response.json`) to see what the JSON payload of the response is.

* Change the `set -e` line at the top to `set -ex`. It'll then print each line before it executes.

## Notes on the Script

* Why `curl ipify.org` as opposed to `dig myip.opendns.com`?

    `dig myip.opendns.com` is indeed faster (as noted by the original Cloudflare ddns script I linked in the intro). However, without DNSSEC or any form of DNS authentication, it's possible for a man-in-the-middle attacker to change what your A record points to simply by giving you a faked answer from `opendns.com`. With `ipify.org`'s TLS-protected API, it's harder. I didn't think the slight speed and lower data usage warranted the downgrade in security.

* How fast will this update the DNS record when my IP changes?

    If the record's TTL is 300 seconds and the timer is run every 5 minutes, the maximum possible lag should be 10 minutes.