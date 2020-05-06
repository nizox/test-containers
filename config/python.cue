package main

import (
	"strings"
	"blocklayer.dev/bl"
)

PythonApp :: {
	description?: string

	pythonVersion: string
	baseImage: {
		name: "python"
		tag: pythonVersion
	}
	env: {
		[string]: string
	}

	app: {
		dir: string | *"/app"
		script: string | *"run.sh"
	}

	port: int | *8080

	source: bl.Directory

	Dockerfile ::
		"""
		FROM \(baseImage.name):\(baseImage.tag)
		\(strings.Join(["ENV \(k)=\(v)" for k, v in env], "\n"))

		RUN mkdir \(app.dir)
		WORKDIR \(app.dir)
		COPY /requirements.txt \(app.dir)/requirements.txt
		RUN pip install --no-cache-dir -r requirements.txt
		ADD / \(app.dir)/

		ENV PORT=\(port)
		EXPOSE \(port)
		ENTRYPOINT ["\(app.dir)/\(app.script)"]
		"""

	Build :: bl.Build & {
		context: source
		dockerfile: Dockerfile
	}
	// FIXME: skip the intermediary "build" field (not yet supported by Blocklayer engine)
	// build: Build
	build: bl.Build & {
		context: source
		dockerfile: Dockerfile
	}

	// image: build.image
}
