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

	apps: [string]: [string]: #PythonApp
	for frameworkName, _ in frameworkNames {
		for pythonVersion, _ in pythonVersions {
			apps: "\(frameworkName)": "\(pythonVersion)": #PythonApp & {
				source: bl.Directory & {
					"source": env.assets
					path: frameworkName
				}
				"pythonVersion": pythonVersion
				description: "\(frameworkName) on python \(pythonVersion)"
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
}

ls: bl.BashScript & {
	input: "/flask": bl.Directory & {
		source: env.assets
		path: "flask"
	}
	output: "/result": string
	code: """
	ls -l /flask > /result
	"""
}
