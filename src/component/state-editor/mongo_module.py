import json

attrs = {
		'general'	:	{
			'wait'	:	{
				'module'	:	'general.wait',
				'reference'	:	{
					'en'	:	'''
### Description
    wait for remote state(s) to complete, if anyone is not done yet, it will cause the host to block on the waiting.
    
### Parameters

*   **state** (*required*): one or multiple remote states to be waited
        example:
            single - @hostname.state_id
            barrier - @host1.state_1, @host2.state_2
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'state'	:	{
						'type'		:	'state',	# state is an array
						'required'	:	True
					}
				}
			}
		},
		'windows'	:	{},
		'linux'		:	{
			'apt pkg'	:	{
				'module'	:	'package.apt.package',
				'reference'	:	{
					'en'	:	'''
### Description
 ensure APT-based packages installed or removed (with the specified version)

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package


* **repo** (*optional*): the APT repo name, which you want to use for installing the packages
		main

* **debconf** (*optional*):
		/etc/apt/deb.conf
	
* **verify_gpg** (*optional*): verify the package's GPG siganature, by default ***True***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'	:	'dict',
						'option'	:	['latest', 'removed', 'purged'],	# autofill options to show in IDE
						'default'	:	'',			# the default value to show in IDE,
						'required'	:	True
					},
					'fromrepo'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'debconf'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'verify_gpg':	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					}
				}
			},
			'apt repo'	:	{
				'module'	:	'package.apt.repo',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure the specified APT repository is present and enabled

### Parameters

*   **name** (*required*): the repository name
		main

* **content** (*required*): the content of the repository configuration file
	
		deb http://extras.ubuntu.com/ubuntu precise main
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'	:	'line',
						'required'	:	True
					},
					'content'	:	{
						'type'	:	'line',
						'required'	:	True
					}
				}
			},
			'gem'	:	{
				'module'	:	'package.gem.package',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure ruby gems are installed

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'		:	'dict',
						'option'	:	['latest', 'removed'],	# autofill options to show in IDE
						'default'	:	'',			# the default value to show in IDE,
						'required'	:	True
					}
				}
			},
			'npm'	:	{
				'module'	:	'package.npm.package',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure node.js packages are installed

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'		:	'dict',
						'value'		:	['latest', 'removed'],	# values to show in IDE
						'default'	:	'',						# the default value of the item,
						'required'	:	True
					}
				}
			},
			#'pear'	:	{
			#	'module'	:	'package.pear.package',
			#	'reference'	:	{
			#		'en'	:	'''''',
			#		'cn'	:	''''''
			#	},
			#	'parameter'	:	{
			#		'name'	:	{
			#			'type'		:	'dict',
			#			'value'		:	['latest', 'removed'],	# values to show in IDE
			#			'default'	:	'',			# the default value of the item
			#			'required'	:	True
			#		}
			#	}
			#},
			#'pecl.package'	:	{
			#	'module'	:	'package.pecl.package',
			#	'reference'	:	{
			#		'en'	:	'''''',
			#		'cn'	:	''''''
			#	},
			#	'parameter'	:	{
			#		'name'	:	{
			#			'type'	:	'dict',
			#			'value'		:	['latest', 'removed'],	# values to show in IDE
			#			'default'	:	'',			# the default value of the item
			#			'required'	:	True
			#		}
			#	}
			#},
			'pip'	:	{
				'module'	:	'package.pip.package',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure pip packages are installed

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'	:	'dict',
						'value'		:	['latest', 'removed'],	# values to show in IDE
						'default'	:	'',			# the default value of the item
						'required'	:	True
					}
				}
			},
			'yum.package'	:	{
				'module'	:	'package.yum.package',
				'reference'	:	{
					'en'	:	'''
### Description
	install or remove rpm packages with yum

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package

* **fromrepo** (*optional*): an repo name, which you want to use for installing the packages
		epel

* **enablerepo** (*optional*): a disabled repo name, which you want to enable for installing the packages
		epel

* **disablerepo** (*optional*): an enabled repo name, which you want to disable for installing the packages
		epel
	
* **verify_gpg** (*optional*): verify the package's GPG siganature, by default ***True***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'	:	'dict',
						'value'		:	['latest', 'removed'],	# values to show in IDE
						'default'	:	'',			# the default value of the item
						'required'	:	True
					},
					'fromrepo'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'enablerepo'	:	{
						'type'	:	'line',
						'required'	:	False
					},
					'disablerepo'	:	{
						'type'	:	'line',
						'required'	:	False
					},
					'verify_gpg'	:	{
						'type'		:	'bool',
						'default'	:	True,
						'required'	:	False
					}
				}
			},
			'yum.repo'	:	{
				'module'	:	'package.yum.repo',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure rpm packages are installed

### Parameters

*   **name** (*required*): the repo name
		   epel
 
* **content** (*required*): the content of the repo configuration file 
		[10gen]
		name=10gen Repository
		baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686
		gpgcheck=0
		enabled=1
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'content'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'zypper.package'	:	{
				'module'	:	'package.zypper.package',
				'reference'	:	{
					'en'	:	'''
### Description
	install and remove rpm package with zypper

### Parameters

*   **name** (*required*): the package names and versions. You can specify multiple pakages. The following values can be used for package version:
	- <***empty***> (*default*): ensure the package is present. If not, will install the latest version available of all APT repos on                   
	- <***version***>: ensure the package is present, with the version specified. If the version in unavailable of all APT repos on the host, the state will fail
	- **latest**: ensure the package is present with the latest version. If a newer version is available of all APT repos on the host, will do a auto-upgrade
	- **removed**: ensure the package is absent
	- **purged**: ensure the package is absent, and also delete all related configuration data of the package
 

* **fromrepo** (*optional*): an repo name, which you want to use for installing the packages
		epel
	
* **verify_gpg** (*optional*): verify the package's GPG siganature, by default ***True***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'	:	{
						'type'	:	'dict',
						'value'		:	['latest', 'removed'],	# values to show in IDE
						'default'	:	'',			# the default value of the item
						'required'	:	True
					},
					'fromrepo'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'verify_gpg'	:	{
						'type'		:	'bool',
						'default'	:	True,
						'required'	:	False
					}
				}
			},
			'zypper.repo'	:	{
				'module'	:	'package.zypper.repo',
				'reference'	:	{
					'en'	:	'''
### Description
	ensure a zypper is present and enabled

### Parameters

*   **name** (*required*): the repo name
		   packman
 

* **url** (*required*): the repo url
		http://ftp.gwdg.de/pub/linux/packman/suse/13.1/
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'url'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'dir'	:	{
				'module'	:	'path.dir',
				'reference'	:	{
					'en'	:	'''
### Description
	manage the specified directory

### Parameters

*   **path** (*required*): the directory path
		example:
			/var/www/html

		note:
			This state ensures the specifed directory is present with correposnding attributes. If the parent directory is present, its attributes will be left unchanged, otherwise it will be created with the same attributed of the specified directory itself.
 
* **user** (*optional*): the user name of the directory owner
		example:
			root
	
		note:
			If specified, the directory owner will be set to this user. Otherwise, the result depends on whether the directory exists. If so, the directory owner will be left unchanged. If not, the directory will be created under the user name of which the Madeira agent runs.

* **group** (*optional*): the group name of the directory owner
		example:
			root
	
		note:
			If specified, the directory will be set to this group. Otherwise, the result depends on whether the directory exists. If so, the directory group will be left unchanged. If not, the directory will be created under the group of which the Madeira agent runs.

* **mode** (*optional*): the directory mode
		example:
			0755
	
		note:
			If specified, the directory will be set to this mode. Otherwise, the result depends on whether the directory exists. If so, the directory mode will be left unchanged. If not, the directory will be created with the default mode 0755

* **recursive** (*optional*): whehther to recursively set attributes of all sub-directories under *path*, by default ***True***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'path'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'user'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'group'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'mode':	{
						'type'		:	'line',
						'default'	:	'0755',
						'required'	:	False
					},
					'recursive'	:	{
						'type'		:	'bool',
						'default'	:	True,
						'required'	:	False
					}
				}
			},
			'file'	:	{
				'module'	:	'path.file',
				'reference'	:	{
					'en'	:	'''
### Description
	manage the specified file

### Parameters

*   **path** (*required*): the file path
		example:
			/root/.ssh/known_hosts

		note:
			This state ensures the specifed file is present with correposnding attributes and content. If the directory is present, its attributes will be left unchanged, otherwise it will be created with the same attributed of the specified file itself.
 
* **user** (*optional*): the user name of the file owner
		example:
			root
	
		note:
			If specified, the file owner will be set to this user. Otherwise, the result depends on whether the file exists. If so, the file owner will be left unchanged. If not, the file will be created under the user name of which the Madeira agent runs.

* **group** (*optional*): the group name of the file owner
		example:
			root
	
		note:
			If specified, the file will be set to this group. Otherwise, the result depends on whether the file exists. If so, the file group will be left unchanged. If not, the file will be created under the group of which the Madeira agent runs.

* **mode** (*optional*): the directory mode
		example:
			0755
	
		note:
			If specified, the file will be set to this mode. Otherwise, the result depends on whether the file exists. If so, the file mode will be left unchanged. If not, the file will be created with the default mode 0755

* **content** (*required*): the file content
		note:
			If the specified file exists, the file will be reset, otherwise the file will be created with this content
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'path'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'user'	:	{
						'type'		:	'line',
						'required'	:	True,
					},
					'group'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'mode':	{
						'type'		:	'line',
						'default'	:	'0755',
						'required'	:	True
					},
					'content'	:	{
						'type'		:	'text',
						'required'	:	True
					}
				}
			},
			'symlink'	:	{
				'module'	:	'path.symlink',
				'reference'	:	{
					'en'	:	'''
### Description
	manage a symlink

### Parameters

*   **source** (*required*): the path to link to
		example:
			/data/
 
* **target** (*required*): the path to the symlink
		example:
			/mnt/data/
	
		note:
			If the target's parent path does not exist, this state will fail.
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'source'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'target'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'git'	:	{
				'module'	:	'scm.git',
				'reference'	:	{
					'en'	:	'''
### Description
	manage the git repo
	
### Parameters

*   **repo** (*required*): the git repository uri
		example:
			local - /opt/git/project.git or file:///opt/git/project.git
			ssh - ssh://user@server/project.git
			http/https - https://example.com/gitproject.git
			git - git://example.com/gitproject.git

* **branch** (*optional*): the branch to checkout
		example:
			master
	
		note:
			When using <branch>, the local repo will be kept synchronized with the latest commit of the specified branch.
			Do NOT use <branch> and <version> at the same time

* **version** (*optional*): the version to checkout
		example:
			tag name - release-1.0
			commit id - 8b1e0f7e499f9af07eed5ba6a3fc5490e72631b6
	
		note:
			When using <version>, the local repo will remain the specified tag or commit.
			Do NOT use <branch> and <version> at the same time

* **ssh_key** (*optional*): the path of the ssh keypair file
		example:
			/root/.ssh/id_rsa

* **path** (*required* ): the path to clone the repo
		example:
			/var/www/mysite/

* **user** (*optional*): the user name of the file owner
		example:
			root
	
		note:
			If specified, the file owner will be set to this user. Otherwise, the result depends on whether the file exists. If so, the file owner will be left unchanged. If not, the file will be created under the user name of which the Madeira agent runs.

* **group** (*optional*): the group name of the file owner
		example:
			root
	
		note:
			If specified, the file will be set to this group. Otherwise, the result depends on whether the file exists. If so, the file group will be left unchanged. If not, the file will be created under the group of which the Madeira agent runs.

* **mode** (*optional*): the directory mode
		example:
			0755
	
		note:
			If specified, the file will be set to this mode. Otherwise, the result depends on whether the file exists. If so, the file mode will be left unchanged. If not, the file will be created with the default mode 0755

* **force** (*optional*): force the checkout even if there is conflict, by default ***False***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'repo'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'branch'	:	{
						'type'		:	'line',
						'default'	:	'master',
						'required'	:	False
					},
					'version'	:	{
						'type'		:	'line',
						'default'	:	'',
						'required'	:	False
					},
					'ssh_key'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'path'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'user'	:	{
						'type'		:	'line',
						'required'	:	False,
					},
					'group'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'mode':	{
						'type'		:	'line',
						'default'	:	'0755',
						'required'	:	False
					},
					'force':	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					}
				}
			},
			'hg'	:	{
				'module'	:	'scm.hg',
				'reference'	:	{
					'en'	:	'''
### Description
	manage the hg repo
	
### Parameters

*   **repo** (*required*): the hg repository uri
		example:
			local - /path/to/repo
			ssh - ssh://user@server/path/to/repo
			http/https - https://example.com/path/to/repo

* **branch** (*optional*): the branch to checkout
		example:
			default
	
		note:
			When using <branch>, the local repo will be kept synchronized with the latest commit of the specified branch.
			Do NOT use <branch> and <version> at the same time

* **revision** (*optional*): the version to checkout
		example:
			tag name - release-1.0
			changeset - 8b1e0f7e499f9af07eed5ba6a3fc5490e72631b6
	
		note:
			When using <version>, the local repo will remain the specified tag or commit.
			Do NOT use <branch> and <version> at the same time

* **ssh_key** (*optional*): the path of the ssh keypair file
		example:
			/root/.ssh/id_rsa

* **path** (*required* ): the path to clone the repo
		example:
			/var/www/mysite/

* **user** (*optional*): the user name of the file owner
		example:
			root
	
		note:
			If specified, the file owner will be set to this user. Otherwise, the result depends on whether the file exists. If so, the file owner will be left unchanged. If not, the file will be created under the user name of which the Madeira agent runs.

* **group** (*optional*): the group name of the file owner
		example:
			root
	
		note:
			If specified, the file will be set to this group. Otherwise, the result depends on whether the file exists. If so, the file group will be left unchanged. If not, the file will be created under the group of which the Madeira agent runs.

* **mode** (*optional*): the directory mode
		example:
			0755
	
		note:
			If specified, the file will be set to this mode. Otherwise, the result depends on whether the file exists. If so, the file mode will be left unchanged. If not, the file will be created with the default mode 0755

* **force** (*optional*): force the checkout even if there is conflict, by default ***False***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'repo'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'branch'	:	{
						'type'		:	'line',
						'default'	:	'default',
						'required'	:	True
					},
					'revision'	:	{
						'type'		:	'line',
						'default'	:	'',
						'required'	:	True
					},
					'ssh_key'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'path'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'user'	:	{
						'type'		:	'line',
						'required'	:	False,
					},
					'group'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'mode':	{
						'type'		:	'line',
						'default'	:	'0755',
						'required'	:	False
					},
					'force':	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					}
				}
			},
			'svn'	:	{
				'module'	:	'scm.svn',
				'reference'	:	{
					'en'	:	'''
### Description
	manage the hg repo
	
### Parameters

*   **repo** (*required*): the hg repository uri
		example:
			local - file:///path/to/repo
			http - http://example.com/path/to/repo
			https - https://example.com/path/to/repo
			svn - svn://example.com/path/to/repo
			svn+ssh - svn+ssh://user@example.com/path/to/repo

* **branch** (*optional*): the branch to checkout
		example:
			master
	
		note:
			When using <branch>, the local repo will be kept synchronized with the latest commit of the specified branch.
			Do NOT use <branch> and <version> at the same time

* **revision** (*optional*): the version to checkout
		example:
			tag name - release-1.0
			changeset - 8b1e0f7e499f9af07eed5ba6a3fc5490e72631b6
	
		note:
			When using <version>, the local repo will remain the specified tag or commit.
			Do NOT use <branch> and <version> at the same time

* **username** (*optional*): the username of the svn server

* **password** (*optional*): the password of the svn user

* **path** (*required* ): the path to checkout the repo
		example:
			/var/www/mysite/

* **user** (*optional*): the user name of the file owner
		example:
			root
	
		note:
			If specified, the file owner will be set to this user. Otherwise, the result depends on whether the file exists. If so, the file owner will be left unchanged. If not, the file will be created under the user name of which the Madeira agent runs.

* **group** (*optional*): the group name of the file owner
		example:
			root
	
		note:
			If specified, the file will be set to this group. Otherwise, the result depends on whether the file exists. If so, the file group will be left unchanged. If not, the file will be created under the group of which the Madeira agent runs.

* **mode** (*optional*): the directory mode
		example:
			0755
	
		note:
			If specified, the file will be set to this mode. Otherwise, the result depends on whether the file exists. If so, the file mode will be left unchanged. If not, the file will be created with the default mode 0755

* **force** (*optional*): force the checkout even if there is conflict, by default ***False***
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'uri'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'branch'	:	{
						'type'		:	'line',
						'default'	:	'master',
						'required'	:	True
					},
					'revision'	:	{
						'type'		:	'line',
						'default'	:	'',
						'required'	:	True
						
					},
					'username'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'password'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'path'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'user'	:	{
						'type'		:	'line',
						'required'	:	False,
					},
					'group'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'mode':	{
						'type'		:	'line',
						'default'	:	'0755',
						'required'	:	False
					},
					'force':	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					}
				}
			},
			'sysvinit'	:	{
				'module'	:	'service.sysvinit',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the SysV service
    
### Parameters

*   **name** (*required*): the service name
        example:
            httpd

*   **watch** (*optional*): watch a list of files or directories, restart the service if any of them is modified
        example:
            /etc/nginx/nginx.conf, /etc/my.cnf
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'watch'		:	{
						'type'		:	'array',
						'required'	:	False
					}
				}
			},
			'upstart'	:	{
				'module'	:	'service.upstart',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the Upstart service
    
### Parameters

*   **name** (*required*): the service name
        example:
            httpd

*   **watch** (*optional*): watch a list of files or directories, restart the service if any of them is modified
        example:
            /etc/nginx/nginx.conf, /etc/my.cnf
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'watch'		:	{
						'type'		:	'array',
						'required'	:	False
					}
				}
			},
			'supervisord'	:	{
				'module'	:	'service.supervisord',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the Supervisord service
    
### Parameters

*   **name** (*required*): the service name
        example:
            httpd

*   **config** (*required*): the path of supervisord configuration file
        example:
            /etc/supervisord

        note:
            When this file is modified, supervisord will be restarted, which causes all managed services restarted

*   **watch** (*optional*): watch a list of files or directories, restart the service if any of them is modified
        example:
            /etc/nginx/nginx.conf, /etc/my.cnf
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'name'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'watch'		:	{
						'type'		:	'array',
						'required'	:	False
					},
					'config'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'cron'	:	{
				'module'	:	'sys.cron',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the cron jobs
    
### Parameters

*   **username** (*optional*): the user to execute the cron job
        note:
            if blank, use will use root by default

*   **cmd** (*required*): the command to execute
        example:
            cat /proc/meminfo >> /tmp/meminfo

*   **minute** (*optional*): 0 - 59

*   **hour** (*optional*): 0 - 23 (must be a valid day if a month is specified)

*   **day of month** (*optional*): 1 - 31

*   **month** (*optional*): 1 - 12

*   **day of week** (*optional*): 0 - 7, sunday is represented by 0 or 7, monday by 1
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'minute'	:	{
						'type'		:	'line',
						'option'	:	['*'],
						'required'	:	False
					},
					'hour'	:	{
						'type'		:	'line',
						'option'	:	['*'],
						'required'	:	False
					},
					'day of month'	:	{
						'type'		:	'line',
						'option'	:	['*'],
						'required'	:	False
					},
					'month'	:	{
						'type'		:	'line',
						'option'	:	['*'],
						'required'	:	False
					},
					'day of week'	:	{
						'type'		:	'line',
						'option'	:	['*'],
						'required'	:	False
					},
					'username'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'cmd'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'fs'	:	{
				'module'	:	'sys.fs',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the filesystem
    
### Parameters

*   **dev** (*required*): the device name
        example:
            /dev/sda1

*   **filesystem** (*required*): the filesystem type of the device    

*   **force** (*optional*): forcefully create the new filesystem, even if there is already one on the specified device, by default *False*

*   **opts** (*optional*): additional options for creating the filesystem, see *MKE2FS(8)*
            example:
                -O journal_dev [ -b block-size ] [ -L volume-label ] [ -n ] [ -q ] [ -v ]  external-journal [ blocks-count ]
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'dev'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'filesystem':	{
						'type'		:	'line',
						'option'	:	['ext2', 'ext3', 'ext4', 'btrfs', 'reiserfs', 'xfs', 'zfs'],
						'required'	:	True
					},
					'opts':	{
						'type'		:	'line',
						'required'	:	False
					},
					'force'		:	{
						'type'		:	'bool',
						'default'	:	True,
						'required'	:	False
					}
				}
			},
			'hosts'	:	{
				'module'	:	'sys.hosts',
				'reference'	:	{
					'en'	:	'''
### Description
    manage /etc/hosts
    
### Parameters

*   **ip** (*required*): the IP address

*   **hostnames** (*required*): a list of hostnames
        example:
            web, web.example.com
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'ip'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'hostnames'	:	{
						'type'		:	'array',
						'required'	:	True
					},
				}
			},
			'hostname'	:	{
				'module'	:	'sys.hostname',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the host's hostname
### Parameters

*   **hostname** (*required*): the hostname
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'hostname'	:	{
						'type'		:	'line',
						'required'	:	True
					}
				}
			},
			'mount'	:	{
				'module'	:	'sys.mount',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the mount points in /etc/fstab
    
### Parameters

*   **path** (*required*): the path of the mount point

*   **dev** (*required*): the device name

*   **filesystem** (*required*): the file system type of the device

*   **dump** (*optional*): the dump value in /etc/fstab, see *fstab(8)*

*   **passno** (*optional*): the pass value in /etc/fstab, see *fstab(8)*

*   **opts** (*optional*): a list of options for /etc/fstab
            example:
                noatime
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'path'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'dev'	:	{
						'type'		:	'line',
						'option'	:	['ext2', 'ext3', 'ext4', 'btrfs', 'iso9660', 'ntfs', 'reiserfs', 'xfs', 'zfs'],
						'required'	:	True
					},
					'filesystem':	{
						'type'		:	'line',
						'required'	:	True
					},
					'dump':	{
						'type'		:	'line',
						'default'	:	'0',
						'required'	:	False
					},
					'passno':	{
						'type'		:	'line',
						'default'	:	'0',
						'required'	:	False
					},
					'opts':	{
						'type'		:	'line',
						'required'	:	False
					}
				}
			},
			'cmd'	:	{
				'module'	:	'sys.cmd',
				'reference'	:	{
					'en'	:	'''
### Description
    execute a shell command
    
### Parameters

*   **cmd** (*required*): the command to execute
        example:
            find . -name *.pyc | xargs rm

*   **cwd** (*optional*): the current working directory to execute the command, be default */madeira/tmp/*

*   **user** (*optional*): the user to execute the command, be default the user which the agent runs as

*   **group** (*optional*): the group to execute the command, be default the group which the agent runs as

*   **env** (*optional*): environment variables for the command

*   **timeout** (*optional*): command timeout, by default *600* (in seconds)
        note:
            By default, a command will be terminated and taken "failed" if not finishe in 600 seconds. However you can change with    this option.

*   **with_path** (*optional*): the command will not run if the specified path exists

*   **without_path** (*optional*): the command will not run if the specified path does not exist
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'bin'		:	{
						'type'		:	'line',
						'option'	:	'',
						'default'	:	'bin/sh',
						'required'	:	False
					},
					'cmd'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'cwd'		:	{
						'type'		:	'line',
						'default'	:	'/madeira/tmp/',
						'required'	:	False
					},
					'user'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'group'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'timeout'	:	{
						'type'		:	'line',
						'default'	:	600,
						'required'	:	True
					},
					'env'		:	{
						'type'		:	'dict',
						'required'	:	False
					},
					'with_path'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'without_path'	:	{
						'type'		:	'line',
						'required'	:	False
					}
				}
			},
			'user'	:	{
				'module'	:	'sys.user',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the user
    
### Parameters

*   **username** (*required*): the user name

*   **password** (*required*): the encrypted value of the password
        note:
            use "openssl passwd -salt <salt> -1 <plaintext>" to generate the passworld hash

*   **fullname** (*optional*): the full name of the user

*   **uid** (*optional*): the user id

*   **gid** (*optional*): the group id

*   **home** (*optional*): the home directory of the user
        note:
            if the directory already exists, the user and group of the directory will be set to this user; otherwise, the directory (and its parent directories) will be created, with the user and group of the user.

*   **nologin** (*optional*): whether to allow user to login, by default *False*

*   **groups** (*optional*): a list of groups of the user
        note:
            if pass in an empty list, all groups of the user will be removed except the defaut one
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'username'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'password'	:	{
						'type'		:	'line',
						'required'	:	True
					},
					'fullname'	:	{
						'type'		:	'line',
						'required'	:	False
					},
					'uid'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'gid'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'home'		:	{
						'type'		:	'line',
						'default'	:	'/home/$username',		# TODO:
						'required'	:	False
					},
					'nologin'	:	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					},
					'groups'	:	{
						'type'		:	'array',
						'required'	:	False
					},
				}
			},
			'group'	:	{
				'module'	:	'sys.user',
				'reference'	:	{
					'en'	:	'''
### Description
    manage the group
    
### Parameters

*   **groupname** (*required*): the group name

*   **gid** (*optional*): the group id

*   **system** (*optional*): whether this is a system group, by default *False*
					''',
					'cn'	:	''''''
				},
				'parameter'	:	{
					'groupname'		:	{
						'type'		:	'line',
						'required'	:	True
					},
					'gid'		:	{
						'type'		:	'line',
						'required'	:	False
					},
					'system'		:	{
						'type'		:	'bool',
						'default'	:	False,
						'required'	:	False
					}
				}
			},
			'ntp'	:	{},
			'quota'	:	{},
			'lvm'	:	{},
			'ssh'	:	{},
			'raid'	:	{},
			'iptabes'	:	{}
		}
	}

f = open('data.js', 'w')
f.write('var data = ' + json.dumps(attrs))