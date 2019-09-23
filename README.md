Hiera data_hash for pass repository
===================================

This Puppet module provides a `data_hash` function for Hiera to look up keys in
pass GPG password repositories.


## Usage

### Requirements

You need to install the `ruby_gpg` gem on your Puppet Master:

```shell
$ puppetserver gem install ruby_gpg
```

You also need to GPG key for your Puppet Master, allowed to decipher the
passwords in your pass store.


### Setup

In your `hiera.yaml`, set the `data_hash` key to `pass_data`, e.g.:

```yaml
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "Pass"
    datadir: "/home/foo/.password-store"
    data_hash: pass_data
    glob: "%{::project}/*.gpg"
  - name: "Common"
    path: common.yaml
```
