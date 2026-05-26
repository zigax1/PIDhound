TESTING_FRAMEWORKS = /Library/Developer/CommandLineTools/Library/Developer/Frameworks
XSWIFTC_F = -Xswiftc -F -Xswiftc $(TESTING_FRAMEWORKS)

.PHONY: build test clean run-cli run-app

build:
	swift build

test:
	swift test $(XSWIFTC_F) $(ARGS)

clean:
	rm -rf .build

run-cli:
	swift run pidhound-cli $(ARGS)

run-app:
	swift run pidhound
