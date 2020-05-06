package test

import (
	"strings"

	"b.l/bl"
	"stackbrew.io/git"
)

Fragment :: {
	name: string
	template: string
	...
}

AppImage :: {
	fragments: [...Fragment]
}


// TODO use struct instead of list of fragments

PythonFragment :: Fragment & {
	runtime_version: string
	name: "python:\( runtime_version )"
	template: "FROM python:\( runtime_version )\nENV PYTHON_BIN=python\( runtime_version )"
}

python_versions :: [ "2.7", "3.5", "3.6", "3.7", "3.8" ]

StubAppFragment :: Fragment & {
	app: string
	name: "stub:\( app )"
	template: """
RUN mkdir /app
WORKDIR /app

COPY assets/\( app )/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

ADD assets/\( app )/ /app/

ARG PORT=8080
ENV PORT=${PORT}
EXPOSE ${PORT}

ENTRYPOINT ["/app/run.sh"]
"""
}

combinations: [
	AppImage & {
		fragments: [
			PythonFragment & { runtime_version: python },
			StubAppFragment & { app: "flask" }
		]
	}
	for python in python_versions
]

repo: git.Repository & {
	url: "https://github.com/nizox/test-containers"
}

images: {
	for image in combinations {
		"\( image.fragments[0].runtime_version )": bl.Build & {
			context: repo.out
			dockerfile: strings.Join(["### \( fragment.name ) ###\n" + fragment.template for fragment in image.fragments], "\n\n")
		}
	}
}
