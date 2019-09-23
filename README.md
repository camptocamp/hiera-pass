Hiera data_hash for pass repository
===================================

This Puppet module provide two Hiera backends to look up keys in
pass GnuPG password repositories.


## Usage

### Requirements

You need to install the `ruby_gpg` gem on your Puppet Master:

```shell
$ puppetserver gem install ruby_gpg
```

You also need to GnuPG key for your Puppet Master, allowed to decipher the
passwords in your pass store.


### Setup


Example set up with both `data_hash` and `lookup_key` backends:


```yaml
---
version: 5
defaults:
  datadir: data
  data_hash: yaml_data
hierarchy:
  - name: "Pass data_hash"
    datadir: "/home/foo/.password-store"
    data_hash: pass_data
    glob: "%{::project}/*.gpg"
  - name: "Pass lookup_key"
    datadir: "/home/foo/.password-store"
    lookup_key: pass_lookup_key
    path: "%{::project}"
  - name: "Common"
    path: common.yaml
```

### Usage

The `pass_data` Hiera backend works just like the `yaml_data` backend, except
it uses GnuPG-encrypted YAML data (following the pass standard).

The `pass_lookup_key` Hiera backend uses the key as the file name to look for
and returns the YAML hash parsed at that location if the file exists.

