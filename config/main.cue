package main

import (
	"blocklayer.dev/bl"
)

env: {
	// App assets. Manually push (for now) using the following command:
	// bl push <DOMAIN> -t env.assets assets/
	assets: bl.Directory
}


#TestApp: {
	frameworkName: string

	#PythonApp & {
		source: bl.Directory & {
			source: env.assets
			path: frameworkName
		}
	}
}


#TestAppGrid: {
	pythonVersions : [version=string]: true

	frameworkNames : [name=string]: true

	apps: [name=string]: [version=string]: #TestApp
	for frameworkName, _ in frameworkNames {
		for pythonVersion, _ in pythonVersions {
			apps: "\(frameworkName)": "\(pythonVersion)": #TestApp & {
				"frameworkName": frameworkName
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
