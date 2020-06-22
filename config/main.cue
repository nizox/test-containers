package main

import (
	"stackbrew.io/git"
)

env: {
	testRepository: git.Repository & {
		url: "https://github.com/nizox/test-containers"
	}
}


#TestApp: {
	frameworkName: string

	#PythonApp & {
		source: {
			dir: env.testRepository.output
			subdir: "assets/\(frameworkName)"
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
