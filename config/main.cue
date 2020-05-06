package test

import (
	"strings"

	"b.l/bl"
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

images: [
	{
		context: local: "."
		dockerfile: strings.Join(["### \( fragment.name ) ###\n" + fragment.template for fragment in image.fragments], "\n\n")
	}
	for image in combinations
]

//test_image: bl.Build & {
//	context: local: "."
//	dockerfile: strings.Join([fragment.template for fragment in combinations[0].fragments], "\n\n")
//}

test: bl.Build & images[0]
