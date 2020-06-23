package main

import (
	"strings"
	"blocklayer.dev/bl"
)

#PythonApp: {
	description?: string

	pythonVersion: string | *"3.8"
	baseImage: {
		name: "python"
		tag: pythonVersion
	}
	env: {
		[string]: string
		PYTHON_BIN: "python\(pythonVersion)"
	}

	app: {
		dir: string | *"/app"
		script: string | *"run.sh"
	}

	port: int | *8080

	source: bl.Directory

	#Dockerfile:
		"""
		FROM \(baseImage.name):\(baseImage.tag)
		\(strings.Join(["ENV \(k)=\(v)" for k, v in env], "\n"))

		RUN mkdir -p \(app.dir)
		COPY /requirements.txt \(app.dir)/requirements.txt
		RUN pip install --no-cache-dir -r \(app.dir)/requirements.txt
		ADD / \(app.dir)/

		ENV PORT=\(port)
		EXPOSE \(port)
		ENTRYPOINT ["\(app.dir)/\(app.script)"]
		"""

	build: bl.Build & {
		context: source
		dockerfile: #Dockerfile
	}
}
