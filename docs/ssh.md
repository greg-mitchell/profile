# SSH Setup

This repo does not set up SSH-related configuration for the LAN, but this doc
explains how to do so and the motivation for the decisions made.

## Setup

Ensure `setup-profile.sh` is run to copy the `.ssh/config` file.

From a computer with the SSH keys already set up, to a destination computer on
the LAN at the IP given by DEST:

```sh
DEST_HOST=192.x.y.z
DEST_DIR="/home/$USER/.ssh"
cd ~/.ssh
scp ./id* "$DEST_HOST:$DEST_DIR"
scp ./config "$DEST_HOST:$DEST_DIR"
ssh-copy-id -i ~/.ssh/id_ed25519_lan_gam7491.pub $DEST_HOST
```

Ensure you can SSH into the destination computer, then edit `/etc/ssh/sshd_config`
to set 

```
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no
```

Restart the service in the system-specific method. Typically one of:

```sh
sudo service ssh restart
sudo systemctl restart sshd
```

## Description

### Preconditions

This configuration assumes that you're configuring a LAN of multiple 'Nix hosts
where each has the same user account. The user may be set if that's different.

Additionally, this setup assumes the LAN is trusted, behind a firewall, and not
exposed to the internet.

The SSH config file additionally assumes that there is a local DNS that assigns
`*.internal` hostnames.

### IP Dest

The script above uses the IP of the destination instead of a DNS name because
my SSH config is configured to use publickey identification for `*.internal`
hosts. Before the public key is added to `authorized_keys`, that's not possible.

### Identity

I've chosen to create a public key pair to represent me on the LAN, and another
for me on the internet. This reduces the blast radius if one should be exposed.

I considered creating a unique user+machine identity, but that would result in
too much of a maintenance headache adding to the authorized keys.

This setup requires adding the LAN identity to all hosts' `authorized_keys` as
well as to their `ssh-agent`s.

### Passwordless SSH

I've chosen to disable password authentication for SSH in my LAN, in part for
convenience (once your `ssh-agent` unlocks the identity, SSH is almost instant)
and in part for security.

The security merits are not clear-cut, since the SSH key is another security-
critical file that must be distributed to new computers I own, but with passkey
enabled, I believe it's a reasonable step towards MFA. More importantly, if I
do screw up and expose a computer to the internet, or if an untrusted device is
on my LAN, even if my password is compromised, it will be unlikely to result in
SSH access to other devices.
