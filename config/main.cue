package main

import (
	"blocklayer.dev/bl"
)

TestApp :: PythonApp & {
	pythonVersion: string
	env: PYTHON_BIN: "python\(pythonVersion)"
	app: script: "run.sh"
}


TestAppGrid :: {
	pythonVersions : [version=string]: true
	// A directory with multiple sources, each in a sub-directory
	sources : [name=string]: bl.Directory

	apps: [name=string]: [version=string]: TestApp
	for sourceName, sourceDir in sources {
		for pythonVersion, _ in pythonVersions {
			apps: "\(sourceName)": "\(pythonVersion)": TestApp & {
				"pythonVersion": pythonVersion
				source: sourceDir
				description: "\(sourceName) on python \(pythonVersion)"
			}
		}
	}
}

// Full test grid
grid : TestAppGrid & {
	pythonVersions : {
		"2.7": true
		"3.5": true
		"3.6": true
		"3.7": true
		"3.8": true
	}
	sources : {
		for name, dir in src {
			"\(name)": dir
		}
	}
}

// App sources. Manually push (for now)
src: {
	flask: bl.Directory
}
