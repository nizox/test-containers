package main

import (
	"strings"
	"blocklayer.dev/bl"
)

#PythonApp: {
	description?: string

	pythonVersion: string | *"3.8"
	extraPackages: {
		[string]: true
		pip: true
	}
	baseImage: {
		name: "python"
		tag: pythonVersion
	}
	env: {
		[string]: string
		PYTHON_BIN: "python\(pythonVersion)"
	}

	app: {
		source: string | *"/"
		dir: string | *"/app"
		script: string | *"\(app.dir)/run.sh"
		port: int | *8080
		wsgi: string | *"stub:app"
	}

	source: bl.Directory

	overrideDockerfile: string | *""

	#Dockerfile:
		"""
		FROM \(baseImage.name):\(baseImage.tag)
		\(strings.Join(["ENV \(k)=\(v)" for k, v in env], "\n"))

		RUN pip install -U --no-cache-dir \(strings.Join([for pkg, _ in extraPackages { pkg }], " "))

		RUN mkdir -p \(app.dir)
		COPY \(app.source)/requirements.txt \(app.dir)/requirements.txt
		RUN pip install --no-cache-dir -r \(app.dir)/requirements.txt
		ADD \(app.source) \(app.dir)/

		ARG PORT=\(app.port)
		ENV PORT=$PORT
		ENV WSGI_APP=\(app.wsgi)

		EXPOSE $PORT
		ENTRYPOINT [\(app.script)]
		\(overrideDockerfile)
		"""

	build: bl.Build & {
		context: source
		dockerfile: #Dockerfile
	}
}
