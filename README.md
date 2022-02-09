
#### Vagrant facade

## Roadmap

- [ ] Tests vagrant file with Rake
- [ ] Libvirt support (Mac ARM/AMD64 / Linux AMD64)

#### Recommanded in machine to work perfectly

- `python3`
- `vagrant`
- `ruby` (>= 2.3)

#### Compatibility

- vmware
- virtualbox
- [ ] libvirt

### Vagrant plugin Context

This plugin is a **facade** aimed at setting easily a virtual vagrant environment

Goal is to provide reusable preconfigured set of tools and Organisation on **vagrant environments** with like :

- VM Config sugar
- Shared folders configured
- Easier Networking
- Issues Workarounds
- Others

---

#### Full config.yaml
> !! Always create this file on project root (`touch config.yaml`)

> Use this same schema in manala.yaml to share a default config

> All variables are set to their default value

```yaml

domain: localhost # format : domain.tld (landrush used)
box: loic-roux-404/deb64-buster # Vagrant cloud box
vb_guest_update: false # Update VirtualBox Guest Additions (for shared folders)
box_update: false # Update box from vagrant cloud
box_version: null # Choose a valid box version
git:
  org: null # provide an username to clone your playbook
  provider: https://github.com # can be https://gitlab.com

paths:
  web: null # not used for now
  host: ./ # Project path on your machine (used by shared folders)
  guest: /vagrant # Project path on guest machine (used by shared folders)

network:
  ip: 192.168.33.10 #NEED TO ADAPT TO YOUR CONFIG
  type: private # Available public private (check vagrant doc)
  dns: true
  # Specify object of type for each port
  # {
  #    guest: 80 # (required)
  #    host: 8080 # (required)
  #    auto_correct: true # (optional)
  #    disabled: false (optional)
  # }
  ports: []
  # NOT TESTED
  # add cert in your machine to enable ssl
  ssl:
    cert: null # cert filename
    path: /etc/ssl # cert path in guest

ansible:
  disabled: false
  playbook: null # git repository name
  inventory: null # Choose inventory (ex : dev prod staging)
  # AVAILABLE :
  # - worker (see script header for playbook-worker.sh)
  # - classic (need ansible on your machine)
  # - local (need ansible on guest machine)
  type: local
  sub_playbook: site.yml # Execute another file under playbook root instead of default site.yml
  vars: # extra_vars for ansible
    keyboard_mac: false

fs:
  type: rsync # AVAILABLE : nfs smb vbox (need vb_guest_update = true)
  opts:
    auto: true # watch enable for rsync
    disabled: true # for all
    ignored: # ignored files in rsync
      - /**/.DS_Store
      - .git
      - .vagrant
      - .idea/
      - .vscode/

provider:
  type: virtualbox
  # Refer to Virtualbox original documentation or `VBoxManage --help `
  # define parameter to the VBoxManage command used by vagrant
  # Params are defined in the config.json file with name=param pair
  # We use this syntax sugar to loop and create dynamic virtualbox vm settings
  # By default vm is modified to 1024Mo RAM & 2 CPU's
  opts:
    memory: 2048
    cpus: 2
    ioapic: on
    # Others settings example
    cpuexecutioncap: 80
    natdnsproxy1: on
    natdnshostresolver1: on
    nictrace1: on
    nictracefile1: .vagrant/dump.pcap
    cableconnected1: on

```

**For vmware :**

```yaml
provider:
  type: vmware
  utility: false # recommanded
  opts:
    allowlist_verified: true
    base_address: ~
    base_mac: ~
    enable_vmrun_ip_lookup: true
    functional_hgfs: false
    gui: false
    linked_clone : true
    nat_device: ~ # fallback to vmnet8
    port_forward_network_pause: 0
    ssh_info_public: false
    unmount_default_hgfs: false
    utility_port: 9922
    utility_certificate_path: ""
    verify_vmnet: true
    vmx: {}

```

## Contribute

#### Test requirements

- [install rvm](https://rvm.io/rvm/install)
- `rvm install 2.6`
- `gem install vg-facade`
- `vagrant plugin install vg-facade-*.gem`

#### Common isues

- solargraph language server on mac os : `sudo gem install solargraph`

#### Error Handling

Component.rb has a class error where your can build complex error to help user

**All** : All these errors have a field `concerned`
which can be string or array of config identifier (ex identifier: `config.network.type`)

**standard** : simply pass the second arg of Error.new for message
