package main

import (
	"blocklayer.dev/bl"
)

env: {
	// App assets. Manually push (for now) using the following command:
	// bl push <DOMAIN> -t env.assets assets/
	assets: bl.Directory
}

#TestAppGrid: {
	pythonVersions : [string]: true

	frameworkNames : [string]: true

	webServerNames: [string]: true

	apps: [string]: [string]: [string]: #PythonApp
	for frameworkName, _ in frameworkNames {
		for pythonVersion, _ in pythonVersions {
			if webServerNames == _|_ {
				apps: "\(frameworkName)": "\(pythonVersion)": "dev": #PythonApp & {
					app: {
						source: frameworkName
					}
					source: env.assets
					"pythonVersion": pythonVersion
					description: "\(frameworkName) dev on python \(pythonVersion)"
				}
			}
			if webServerNames != _|_ {
				for webServerName, _ in webServerNames {
					apps: "\(frameworkName)": "\(pythonVersion)": "\(webServerName)": #PythonApp & {
						app: {
							source: frameworkName
							script: "\(app.dir)/\(webServerName).sh"
						}
						overrideDockerfile: """
						COPY /\(webServerName).sh \(app.dir)
						"""
						extraPackages: {
							"\(webServerName)": true
						}
						source: env.assets
						"pythonVersion": pythonVersion
						description: "\(frameworkName) with \(webServerName) on python \(pythonVersion)"
					}
				}
			}
		}
	}
}

// Full test grid
grid : #TestAppGrid & {
	pythonVersions : {
		"2.7": true
		"3.5": true
		"3.6": true
		"3.7": true
		"3.8": true
	}
	frameworkNames : {
		flask: true
	}
	webServerNames: {
		gunicorn: true
	}
}
